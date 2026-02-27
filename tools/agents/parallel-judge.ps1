param(
    [Parameter(Mandatory = $true)]
    [string]$TaskFile,

    [string]$OutputDir,

    [switch]$DryRun,

    [string]$ProjectScopeFile,

    [string]$CodexExecutable = "codex.cmd",
    [string[]]$CodexArgs = @("exec"),

    [string]$ClaudeExecutable = "claude",
    [string[]]$ClaudeArgs = @("-p"),

    [ValidateSet("codex", "claude", "prompt_only")]
    [string]$JudgeProvider = "claude",

    [string]$JudgeExecutable,
    [string[]]$JudgeArgs,

    [switch]$AllowFailedCandidates,

    [string]$BranchBase,

    [string]$WorktreeRoot,

    [int]$StatusIntervalSeconds = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) {
    $scriptRoot = Split-Path -Parent $PSCommandPath
}

function Ensure-OutputDir {
    param(
        [string]$RequestedDir,
        [string]$ScriptRoot
    )

    $dir = $RequestedDir
    if (-not $dir) {
        $dir = Join-Path $ScriptRoot "logs"
    }

    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

    return (Resolve-Path -Path $dir).Path
}

function Resolve-TextFile {
    param([string]$Path)
    if (Test-Path -Path $Path) {
        return Get-Content -Path $Path -Raw
    }

    return ""
}

function Resolve-ScopeText {
    param(
        [string]$RepoRoot,
        [string]$RequestedScopeFile
    )

    $scopePath = $RequestedScopeFile
    if (-not $scopePath) {
        $scopePath = Join-Path $RepoRoot "tools\agents\PROJECT_SCOPE.md"
    } elseif (-not [System.IO.Path]::IsPathRooted($scopePath)) {
        $scopePath = Join-Path $RepoRoot $scopePath
    }

    if (Test-Path -Path $scopePath) {
        return (Get-Content -Path $scopePath -Raw)
    }

    return "No project scope file found at: $scopePath"
}

function New-JudgePrompt {
    param(
        [string]$TaskPath,
        [string]$TaskBody,
        [string]$CodexOutput,
        [string]$ClaudeOutput,
        [string]$ScopeText
    )

    @"
You are the Arbiter Agent for the rAthena framework.
Choose which candidate should move forward for this task.

Task file:
$TaskPath

Task details:
$TaskBody

Project scope and policies (authoritative):
$ScopeText

Candidate A (codex):
$CodexOutput

Candidate B (claude):
$ClaudeOutput

Evaluation requirements:
- Judge correctness against acceptance criteria first.
- Then judge risk, maintainability, and verification quality.
- If both are weak, return TIE and require revision.

Respond with:
1) Winner: codex | claude | tie
2) Confidence: 0-100
3) Decision Summary
4) Why This Wins
5) Risks
6) Push-Forward Steps
"@
}

function Invoke-Model {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ToolName,
        [Parameter(Mandatory = $true)]
        [string]$Executable,
        [Parameter(Mandatory = $true)]
        [string[]]$Args,
        [Parameter(Mandatory = $true)]
        [string]$Prompt
    )

    if (-not (Get-Command $Executable -ErrorAction SilentlyContinue)) {
        throw "$ToolName executable '$Executable' was not found in PATH."
    }

    $oldErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $response = $Prompt | & $Executable @Args 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $oldErrorPreference

    $responseText = ($response | Out-String)
    if ($null -eq $exitCode) {
        $exitCode = 0
    }

    if ($exitCode -ne 0) {
        Write-Output $responseText
        throw "$ToolName execution failed with exit code $exitCode."
    }

    return $responseText
}

function Invoke-Git {
    param(
        [string]$RepoRoot,
        [string[]]$Arguments,
        [switch]$AllowFailure
    )

    $output = & git -C $RepoRoot @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $outputText = ($output | Out-String).TrimEnd()

    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "git $($Arguments -join ' ') failed in '$RepoRoot' with exit code $exitCode.`n$outputText"
    }

    return [pscustomobject]@{
        ExitCode   = [int]$exitCode
        OutputText = $outputText
    }
}

function Normalize-RefSegment {
    param([string]$Value)

    $normalized = ($Value.ToLowerInvariant() -replace "[^a-z0-9._-]", "-")
    $normalized = $normalized.Trim('-')
    if (-not $normalized) {
        return "task"
    }

    return $normalized
}

function New-AgentBranchName {
    param(
        [string]$TaskId,
        [string]$Agent,
        [string]$Stamp
    )

    $taskSegment = Normalize-RefSegment -Value $TaskId
    $agentSegment = Normalize-RefSegment -Value $Agent
    return "agents/$taskSegment/$agentSegment/$Stamp"
}

function Get-DefaultBranchBase {
    param([string]$RepoRoot)

    $branchResult = Invoke-Git -RepoRoot $RepoRoot -Arguments @("branch", "--show-current")
    $branchName = $branchResult.OutputText.Trim()
    if ($branchName) {
        return $branchName
    }

    $headResult = Invoke-Git -RepoRoot $RepoRoot -Arguments @("rev-parse", "HEAD")
    return $headResult.OutputText.Trim()
}

function New-AgentWorktree {
    param(
        [string]$RepoRoot,
        [string]$RootDir,
        [string]$TaskId,
        [string]$Agent,
        [string]$Stamp,
        [string]$BaseRef
    )

    $branchName = New-AgentBranchName -TaskId $TaskId -Agent $Agent -Stamp $Stamp
    $worktreePath = Join-Path $RootDir $Agent

    if (Test-Path -Path $worktreePath) {
        throw "Worktree path already exists: $worktreePath"
    }

    Invoke-Git -RepoRoot $RepoRoot -Arguments @("worktree", "add", "-b", $branchName, $worktreePath, $BaseRef) | Out-Null

    return [pscustomobject]@{
        Agent       = $Agent
        Branch      = $branchName
        WorktreePath = (Resolve-Path -Path $worktreePath).Path
    }
}

function Format-CandidateMetadata {
    param([pscustomobject]$Result)

    $stagedFilesText = "(none)"
    if ($Result.StagedFiles -and $Result.StagedFiles.Count -gt 0) {
        $stagedFilesText = ($Result.StagedFiles -join [Environment]::NewLine)
    }

    @"
Branch: $($Result.Branch)
Worktree: $($Result.WorktreePath)
Staged file count: $($Result.StagedCount)
Staged files:
$stagedFilesText
"@
}

function Start-AgentJob {
    param(
        [string]$PromptyPath,
        [string]$Agent,
        [string]$TaskPath,
        [string]$OutputPath,
        [string]$RepoRoot,
        [string]$ProjectScopePath,
        [string]$CodexExecutableValue,
        [string[]]$CodexArgsValue,
        [string]$ClaudeExecutableValue,
        [string[]]$ClaudeArgsValue,
        [string]$RequiredBranch,
        [switch]$RequireStagedChanges
    )

    Start-Job -Name $Agent -ArgumentList $PromptyPath, $Agent, $TaskPath, $OutputPath, $RepoRoot, $ProjectScopePath, $CodexExecutableValue, $CodexArgsValue, $ClaudeExecutableValue, $ClaudeArgsValue, $RequiredBranch, $RequireStagedChanges.IsPresent -ScriptBlock {
        param(
            $JobPromptyPath,
            $JobAgent,
            $JobTaskPath,
            $JobOutputPath,
            $JobRepoRoot,
            $JobProjectScopePath,
            $JobCodexExecutable,
            $JobCodexArgs,
            $JobClaudeExecutable,
            $JobClaudeArgs,
            $JobRequiredBranch,
            [bool]$JobRequireStagedChanges
        )

        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Continue"
        Set-Location -Path $JobRepoRoot

        function Get-ChangedFiles {
            param(
                [string]$Repo,
                [string[]]$GitArgs
            )

            $output = & git -C $Repo @GitArgs 2>$null
            if ($LASTEXITCODE -ne 0) {
                return @()
            }

            if ($null -eq $output) {
                return @()
            }

            return @($output | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
        }

        $promptyArgs = @{
            Agent            = $JobAgent
            TaskFile         = $JobTaskPath
            OutputFile       = $JobOutputPath
            ProjectScopeFile = $JobProjectScopePath
            CodexExecutable  = $JobCodexExecutable
            CodexArgs        = $JobCodexArgs
            ClaudeExecutable = $JobClaudeExecutable
            ClaudeArgs       = $JobClaudeArgs
            RepoRoot         = $JobRepoRoot
            RequiredBranch   = $JobRequiredBranch
        }

        if ($JobRequireStagedChanges) {
            $promptyArgs["RequireStagedChanges"] = $true
        }

        $consoleText = ""
        $exitCode = 0

        try {
            $result = & $JobPromptyPath @promptyArgs 2>&1
            $consoleText = ($result | Out-String)
            $exitCode = if ($?) { 0 } else { 1 }
        } catch {
            $consoleText = ($_ | Out-String)
            $exitCode = 1
        }

        $branchName = (& git -C $JobRepoRoot branch --show-current 2>$null | Out-String).Trim()
        $stagedFiles = Get-ChangedFiles -Repo $JobRepoRoot -GitArgs @("diff", "--cached", "--name-only")
        $unstagedFiles = Get-ChangedFiles -Repo $JobRepoRoot -GitArgs @("diff", "--name-only")
        $untrackedFiles = Get-ChangedFiles -Repo $JobRepoRoot -GitArgs @("ls-files", "--others", "--exclude-standard")

        if (-not $branchName) {
            $branchName = $JobRequiredBranch
        }

        if ($exitCode -eq 0 -and $JobRequiredBranch -and $branchName -ne $JobRequiredBranch) {
            $exitCode = 1
            $consoleText += "`nBranch validation failed. Expected '$JobRequiredBranch' but found '$branchName'.`n"
        }

        if ($exitCode -eq 0 -and $JobRequireStagedChanges -and $stagedFiles.Count -eq 0) {
            $exitCode = 1
            $consoleText += "`nStage validation failed. No staged files found for '$branchName'.`n"
        }

        [pscustomobject]@{
            Agent         = $JobAgent
            ExitCode      = [int]$exitCode
            OutputPath    = $JobOutputPath
            ConsoleText   = $consoleText
            Branch        = $branchName
            WorktreePath  = $JobRepoRoot
            StagedFiles   = $stagedFiles
            StagedCount   = [int]$stagedFiles.Count
            UnstagedFiles = $unstagedFiles
            UnstagedCount = [int]$unstagedFiles.Count
            UntrackedFiles = $untrackedFiles
            UntrackedCount = [int]$untrackedFiles.Count
        }
    }
}

$promptyPath = Join-Path $scriptRoot "prompty.ps1"
if (-not (Test-Path -Path $promptyPath)) {
    throw "Missing prompty runner at '$promptyPath'."
}

if ($JudgeProvider -eq "codex") {
    if (-not $JudgeExecutable) {
        $JudgeExecutable = $CodexExecutable
    }
    if (-not $JudgeArgs -or $JudgeArgs.Count -eq 0) {
        $JudgeArgs = $CodexArgs
    }
}

if ($JudgeProvider -eq "claude") {
    if (-not $JudgeExecutable) {
        $JudgeExecutable = $ClaudeExecutable
    }
    if (-not $JudgeArgs -or $JudgeArgs.Count -eq 0) {
        $JudgeArgs = $ClaudeArgs
    }
}

$taskPath = (Resolve-Path -Path $TaskFile).Path
$taskBody = Get-Content -Path $taskPath -Raw
$repoRoot = (Resolve-Path -Path (Join-Path $scriptRoot "..\..")).Path
$resolvedOutputDir = Ensure-OutputDir -RequestedDir $OutputDir -ScriptRoot $scriptRoot
$scopeText = Resolve-ScopeText -RepoRoot $repoRoot -RequestedScopeFile $ProjectScopeFile
$resolvedScopePath = $ProjectScopeFile
if (-not $resolvedScopePath) {
    $resolvedScopePath = Join-Path $repoRoot "tools\agents\PROJECT_SCOPE.md"
} elseif (-not [System.IO.Path]::IsPathRooted($resolvedScopePath)) {
    $resolvedScopePath = Join-Path $repoRoot $resolvedScopePath
}

$taskIdMatch = [regex]::Match($taskBody, "(?m)^#\s*Task ID:\s*(.+)$")
$taskIdRaw = if ($taskIdMatch.Success) { $taskIdMatch.Groups[1].Value.Trim() } else { Split-Path -LeafBase $taskPath }
$taskId = ($taskIdRaw -replace "[^A-Za-z0-9_.-]", "_")
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

$codexOutputPath = Join-Path $resolvedOutputDir "$taskId-codex-$stamp.log"
$claudeOutputPath = Join-Path $resolvedOutputDir "$taskId-claude-$stamp.log"
$decisionPath = Join-Path $resolvedOutputDir "$taskId-decision-$stamp.md"

if ($StatusIntervalSeconds -lt 1) {
    $StatusIntervalSeconds = 15
}

$resolvedBaseRef = if ($BranchBase) { $BranchBase } else { Get-DefaultBranchBase -RepoRoot $repoRoot }
Invoke-Git -RepoRoot $repoRoot -Arguments @("rev-parse", "--verify", $resolvedBaseRef) | Out-Null

$resolvedWorktreeRoot = $WorktreeRoot
if (-not $resolvedWorktreeRoot) {
    $resolvedWorktreeRoot = Join-Path $repoRoot "out\agents\worktrees\$taskId-$stamp"
} elseif (-not [System.IO.Path]::IsPathRooted($resolvedWorktreeRoot)) {
    $resolvedWorktreeRoot = Join-Path $repoRoot $resolvedWorktreeRoot
}

if ($DryRun) {
    if (Test-Path -Path $resolvedWorktreeRoot) {
        $resolvedWorktreeRoot = (Resolve-Path -Path $resolvedWorktreeRoot).Path
    }
} else {
    if (-not (Test-Path -Path $resolvedWorktreeRoot)) {
        New-Item -ItemType Directory -Path $resolvedWorktreeRoot | Out-Null
    }
    $resolvedWorktreeRoot = (Resolve-Path -Path $resolvedWorktreeRoot).Path
}

$codexBranchPreview = New-AgentBranchName -TaskId $taskId -Agent "codex" -Stamp $stamp
$claudeBranchPreview = New-AgentBranchName -TaskId $taskId -Agent "claude" -Stamp $stamp
$codexWorktreePreview = Join-Path $resolvedWorktreeRoot "codex"
$claudeWorktreePreview = Join-Path $resolvedWorktreeRoot "claude"

if ($DryRun) {
    Write-Output "=== Dry Run: Codex Prompt ==="
    & $promptyPath -Agent codex -TaskFile $taskPath -DryRun -ProjectScopeFile $resolvedScopePath -CodexExecutable $CodexExecutable -CodexArgs $CodexArgs -ClaudeExecutable $ClaudeExecutable -ClaudeArgs $ClaudeArgs -RepoRoot $repoRoot -RequiredBranch $codexBranchPreview -RequireStagedChanges
    Write-Output ""
    Write-Output "=== Dry Run: Claude Prompt ==="
    & $promptyPath -Agent claude -TaskFile $taskPath -DryRun -ProjectScopeFile $resolvedScopePath -CodexExecutable $CodexExecutable -CodexArgs $CodexArgs -ClaudeExecutable $ClaudeExecutable -ClaudeArgs $ClaudeArgs -RepoRoot $repoRoot -RequiredBranch $claudeBranchPreview -RequireStagedChanges
    Write-Output ""
    Write-Output "Base ref: $resolvedBaseRef"
    Write-Output "Codex branch/worktree:  $codexBranchPreview @ $codexWorktreePreview"
    Write-Output "Claude branch/worktree: $claudeBranchPreview @ $claudeWorktreePreview"
    Write-Output "Codex output path: $codexOutputPath"
    Write-Output "Claude output path: $claudeOutputPath"
    Write-Output "Decision path: $decisionPath"
    exit 0
}

$codexWorkspace = New-AgentWorktree -RepoRoot $repoRoot -RootDir $resolvedWorktreeRoot -TaskId $taskId -Agent "codex" -Stamp $stamp -BaseRef $resolvedBaseRef
$claudeWorkspace = New-AgentWorktree -RepoRoot $repoRoot -RootDir $resolvedWorktreeRoot -TaskId $taskId -Agent "claude" -Stamp $stamp -BaseRef $resolvedBaseRef

Write-Output "Codex candidate workspace:  branch=$($codexWorkspace.Branch) path=$($codexWorkspace.WorktreePath)"
Write-Output "Claude candidate workspace: branch=$($claudeWorkspace.Branch) path=$($claudeWorkspace.WorktreePath)"

$jobs = @()
$jobs += Start-AgentJob -PromptyPath $promptyPath -Agent "codex" -TaskPath $taskPath -OutputPath $codexOutputPath -RepoRoot $codexWorkspace.WorktreePath -ProjectScopePath $resolvedScopePath -CodexExecutableValue $CodexExecutable -CodexArgsValue $CodexArgs -ClaudeExecutableValue $ClaudeExecutable -ClaudeArgsValue $ClaudeArgs -RequiredBranch $codexWorkspace.Branch -RequireStagedChanges
$jobs += Start-AgentJob -PromptyPath $promptyPath -Agent "claude" -TaskPath $taskPath -OutputPath $claudeOutputPath -RepoRoot $claudeWorkspace.WorktreePath -ProjectScopePath $resolvedScopePath -CodexExecutableValue $CodexExecutable -CodexArgsValue $CodexArgs -ClaudeExecutableValue $ClaudeExecutable -ClaudeArgsValue $ClaudeArgs -RequiredBranch $claudeWorkspace.Branch -RequireStagedChanges

Write-Output "Waiting for both coding agents to finish and stage their branch changes..."
while (($jobs | Where-Object { $_.State -eq "Running" -or $_.State -eq "NotStarted" }).Count -gt 0) {
    $stateSummary = ($jobs | ForEach-Object { "$($_.Name)=$($_.State)" }) -join ", "
    Write-Output ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $stateSummary)
    Wait-Job -Job $jobs -Timeout $StatusIntervalSeconds | Out-Null
}

$results = Receive-Job -Job $jobs
Remove-Job -Job $jobs | Out-Null

$codexResult = $results | Where-Object { $_.Agent -eq "codex" } | Select-Object -First 1
$claudeResult = $results | Where-Object { $_.Agent -eq "claude" } | Select-Object -First 1

if (-not $codexResult -or -not $claudeResult) {
    throw "Parallel run failed to produce both codex and claude results."
}

$codexOutputText = Resolve-TextFile -Path $codexOutputPath
$claudeOutputText = Resolve-TextFile -Path $claudeOutputPath

if (-not $codexOutputText) {
    $codexOutputText = $codexResult.ConsoleText
}
if (-not $claudeOutputText) {
    $claudeOutputText = $claudeResult.ConsoleText
}

$codexOutputText = "$(Format-CandidateMetadata -Result $codexResult)`n$codexOutputText"
$claudeOutputText = "$(Format-CandidateMetadata -Result $claudeResult)`n$claudeOutputText"

$failedCandidates = @()
if ($codexResult.ExitCode -ne 0) {
    $failedCandidates += [pscustomobject]@{
        Agent       = "codex"
        ExitCode    = $codexResult.ExitCode
        OutputPath  = $codexOutputPath
        Branch      = $codexResult.Branch
        Worktree    = $codexResult.WorktreePath
        StagedCount = $codexResult.StagedCount
    }
}
if ($claudeResult.ExitCode -ne 0) {
    $failedCandidates += [pscustomobject]@{
        Agent       = "claude"
        ExitCode    = $claudeResult.ExitCode
        OutputPath  = $claudeOutputPath
        Branch      = $claudeResult.Branch
        Worktree    = $claudeResult.WorktreePath
        StagedCount = $claudeResult.StagedCount
    }
}

if ($failedCandidates.Count -gt 0 -and -not $AllowFailedCandidates) {
    $failureDetails = $failedCandidates | ForEach-Object {
        "$($_.Agent) failed with exit code $($_.ExitCode). branch=$($_.Branch) staged=$($_.StagedCount) worktree=$($_.Worktree) output=$($_.OutputPath)"
    }
    $joined = $failureDetails -join [Environment]::NewLine
    throw "One or more parallel candidates failed. Re-run with -AllowFailedCandidates to continue anyway.`n$joined"
}

$judgePrompt = New-JudgePrompt -TaskPath $taskPath -TaskBody $taskBody -CodexOutput $codexOutputText -ClaudeOutput $claudeOutputText -ScopeText $scopeText

if ($JudgeProvider -eq "prompt_only") {
    Set-Content -Path $decisionPath -Value $judgePrompt -NoNewline
    Write-Output "Parallel run finished."
    Write-Output "Codex branch/worktree:  $($codexResult.Branch) @ $($codexResult.WorktreePath)"
    Write-Output "Claude branch/worktree: $($claudeResult.Branch) @ $($claudeResult.WorktreePath)"
    Write-Output "Codex output:  $codexOutputPath"
    Write-Output "Claude output: $claudeOutputPath"
    Write-Output "Judge prompt:  $decisionPath"
    exit 0
}

if (-not $JudgeExecutable -or -not $JudgeArgs -or $JudgeArgs.Count -eq 0) {
    throw "Judge executable/arguments were not fully configured."
}

if ($JudgeProvider -eq "codex") {
    $decision = Invoke-Model -ToolName "Judge(Codex)" -Executable $JudgeExecutable -Args $JudgeArgs -Prompt $judgePrompt
    Set-Content -Path $decisionPath -Value $decision -NoNewline
    Write-Output $decision
    Write-Output ""
    Write-Output "Codex branch/worktree:  $($codexResult.Branch) @ $($codexResult.WorktreePath)"
    Write-Output "Claude branch/worktree: $($claudeResult.Branch) @ $($claudeResult.WorktreePath)"
    Write-Output "Codex output:  $codexOutputPath"
    Write-Output "Claude output: $claudeOutputPath"
    Write-Output "Decision:      $decisionPath"
    exit 0
}

$decision = Invoke-Model -ToolName "Judge(Claude)" -Executable $JudgeExecutable -Args $JudgeArgs -Prompt $judgePrompt
Set-Content -Path $decisionPath -Value $decision -NoNewline
Write-Output $decision
Write-Output ""
Write-Output "Codex branch/worktree:  $($codexResult.Branch) @ $($codexResult.WorktreePath)"
Write-Output "Claude branch/worktree: $($claudeResult.Branch) @ $($claudeResult.WorktreePath)"
Write-Output "Codex output:  $codexOutputPath"
Write-Output "Claude output: $claudeOutputPath"
Write-Output "Decision:      $decisionPath"
