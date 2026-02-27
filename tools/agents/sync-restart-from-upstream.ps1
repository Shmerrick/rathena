param(
    [string]$UpstreamRemote = "upstream",
    [string]$UpstreamUrl = "https://github.com/rathena/rathena.git",
    [string]$UpstreamBranch = "master",
    [string]$RestartBranch = "RESTART",
    [string]$IntegrationBranch = "RESTART-INTEGRATION",
    [string[]]$ValidationCommands = @(),
    [string]$ValidationCommandPack,
    [switch]$CreateUpstreamRemote,
    [switch]$Promote,
    [switch]$AllowNoValidation,
    [switch]$AllowUntrackedChanges,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($ValidationCommandPack) {
    $packed = @($ValidationCommandPack -split "\|\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
    if ($packed.Count -gt 0) {
        if (@($ValidationCommands).Count -gt 0) {
            $ValidationCommands = @($ValidationCommands + $packed)
        } else {
            $ValidationCommands = @($packed)
        }
    }
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args,
        [switch]$IgnoreFailure
    )

    $cmd = "git " + ($Args -join " ")
    if ($DryRun) {
        Write-Host "[dry-run] $cmd"
        return [pscustomobject]@{
            ExitCode = 0
            Output   = ""
        }
    }

    $oldErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = & git @Args 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $oldErrorPreference
    $text = ($output | Out-String).Trim()

    if ($exitCode -ne 0 -and -not $IgnoreFailure) {
        throw "Command failed ($exitCode): $cmd`n$text"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $text
    }
}

function Invoke-Validation {
    param([Parameter(Mandatory = $true)][string]$Command)

    if ($DryRun) {
        Write-Host "[dry-run] $Command"
        return
    }

    Write-Output "Running validation: $Command"
    & powershell -NoLogo -NoProfile -Command $Command
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Validation command failed ($exitCode): $Command"
    }
}

if (-not $AllowNoValidation -and @($ValidationCommands).Count -eq 0) {
    throw "Provide at least one -ValidationCommands entry, or set -AllowNoValidation."
}

if ($DryRun) {
    $repoRootPath = (Resolve-Path ".").Path
} else {
    $repoRoot = Invoke-Git -Args @("rev-parse", "--show-toplevel")
    if ($repoRoot.ExitCode -ne 0 -or -not $repoRoot.Output) {
        throw "Could not determine git repository root."
    }
    $repoRootPath = $repoRoot.Output
    Set-Location -Path $repoRootPath
}

$status = Invoke-Git -Args @("status", "--porcelain")
if ($status.Output) {
    $statusLines = $status.Output -split "`r?`n" | Where-Object { $_ -ne "" }
    if ($AllowUntrackedChanges) {
        $trackedChanges = @($statusLines | Where-Object { $_ -notmatch '^\?\?' })
        if ($trackedChanges.Count -gt 0) {
            throw "Tracked changes detected. Commit/stash tracked edits before running sync."
        }
        Write-Output "Proceeding with untracked-only working tree changes."
    } else {
        throw "Working tree is not clean. Commit/stash changes before running sync, or use -AllowUntrackedChanges for untracked-only changes."
    }
}

$remoteResult = Invoke-Git -Args @("remote", "get-url", $UpstreamRemote) -IgnoreFailure
if ($remoteResult.ExitCode -ne 0) {
    if (-not $CreateUpstreamRemote) {
        throw "Remote '$UpstreamRemote' is missing. Re-run with -CreateUpstreamRemote."
    }
    Invoke-Git -Args @("remote", "add", $UpstreamRemote, $UpstreamUrl) | Out-Null
    Write-Output "Added remote '$UpstreamRemote' -> $UpstreamUrl"
}

Invoke-Git -Args @("fetch", $UpstreamRemote, $UpstreamBranch) | Out-Null
Write-Output "Fetched $UpstreamRemote/$UpstreamBranch"

$restartExists = Invoke-Git -Args @("show-ref", "--verify", "--quiet", "refs/heads/$RestartBranch") -IgnoreFailure
if ($restartExists.ExitCode -ne 0) {
    Invoke-Git -Args @("checkout", "-b", $RestartBranch, "origin/master") | Out-Null
    Write-Output "Created $RestartBranch from origin/master"
} else {
    Invoke-Git -Args @("checkout", $RestartBranch) | Out-Null
}

Invoke-Git -Args @("checkout", "-B", $IntegrationBranch, $RestartBranch) | Out-Null
Write-Output "Prepared integration branch: $IntegrationBranch"

$mergeResult = Invoke-Git -Args @("merge", "--no-ff", "--no-edit", "$UpstreamRemote/$UpstreamBranch") -IgnoreFailure
if ($mergeResult.ExitCode -ne 0) {
    throw "Merge conflict or merge failure detected on $IntegrationBranch. Resolve manually before continuing."
}
Write-Output "Merged $UpstreamRemote/$UpstreamBranch into $IntegrationBranch"

foreach ($cmd in @($ValidationCommands)) {
    Invoke-Validation -Command $cmd
}
if (@($ValidationCommands).Count -gt 0) {
    Write-Output "Validation commands completed."
}

if ($Promote) {
    Invoke-Git -Args @("checkout", $RestartBranch) | Out-Null
    $promoteResult = Invoke-Git -Args @("merge", "--ff-only", $IntegrationBranch) -IgnoreFailure
    if ($promoteResult.ExitCode -ne 0) {
        throw "Could not fast-forward $RestartBranch from $IntegrationBranch. Promote manually."
    }
    Write-Output "Promoted $IntegrationBranch -> $RestartBranch"
} else {
    Write-Output "Promotion skipped. Review $IntegrationBranch and run with -Promote when ready."
}

Write-Output "Sync workflow complete."
