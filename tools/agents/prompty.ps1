param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("architect", "codex", "claude", "qa", "release", "arbiter")]
    [string]$Agent,

    [Parameter(Mandatory = $true)]
    [string]$TaskFile,

    [string]$OutputFile,

    [switch]$DryRun,

    [string]$ClaudeExecutable = "claude",

    [string[]]$ClaudeArgs = @("-p"),

    [string]$CodexExecutable = "codex.cmd",

    [string[]]$CodexArgs = @("exec"),

    [string]$ProjectScopeFile,

    [string]$RepoRoot,

    [string]$RequiredBranch,

    [switch]$RequireStagedChanges
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) {
    $scriptRoot = Split-Path -Parent $PSCommandPath
}

function New-AgentPrompt {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Profile,
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,
        [Parameter(Mandatory = $true)]
        [string]$TaskPath,
        [Parameter(Mandatory = $true)]
        [string]$TaskBody,
        [Parameter(Mandatory = $true)]
        [string]$ScopeText,
        [string]$RequiredBranch,
        [bool]$RequireStagedChanges
    )

    $operationalRules = @(
        "- Follow AGENTS.md in the repository root."
        "- Follow tools/agents/PROJECT_SCOPE.md policy constraints."
        "- Keep changes tightly scoped to the task."
        "- Prefer concrete command output over assumptions."
        "- Provide verification commands and outcomes."
    )

    if ($RequiredBranch) {
        $operationalRules += "- Work only on git branch: $RequiredBranch."
    }

    if ($RequireStagedChanges) {
        $operationalRules += "- Stage all intended file changes before finishing (do not commit unless explicitly asked)."
    }

    $operationalRulesText = $operationalRules -join [Environment]::NewLine

    @"
You are acting as $($Profile.Name) in the rAthena agent framework.

Role objective:
$($Profile.Objective)

Repository root:
$RepoRoot

Project scope and policies (authoritative):
$ScopeText

Operational rules:
$operationalRulesText

Task file:
$TaskPath

Task details:
$TaskBody

Respond with:
1) Plan
2) Implementation
3) Verification
4) Risks / Follow-ups
"@
}

function Get-AgentProfiles {
    @{
        architect = @{
            Name      = "Architect Agent"
            Objective = "Design implementation plan, dependencies, and risk controls."
            Provider  = "prompt_only"
        }
        codex     = @{
            Name      = "Codex Software Developer"
            Objective = "Implement code changes and document verification steps."
            Provider  = "codex"
        }
        claude    = @{
            Name      = "Claude Software Developer"
            Objective = "Implement code changes, run checks, and summarize risks."
            Provider  = "claude"
        }
        qa        = @{
            Name      = "QA Agent"
            Objective = "Validate behavior, identify regressions, and check coverage gaps."
            Provider  = "prompt_only"
        }
        release   = @{
            Name      = "Release Agent"
            Objective = "Confirm release readiness, packaging, and handoff notes."
            Provider  = "prompt_only"
        }
        arbiter   = @{
            Name      = "Arbiter Agent"
            Objective = "Compare parallel candidate solutions and select the one to move forward."
            Provider  = "claude"
        }
    }
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
        return [pscustomobject]@{
            ExitCode   = 127
            OutputText = "$ToolName executable '$Executable' was not found in PATH."
        }
    }

    $oldErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $response = $Prompt | & $Executable @Args 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $oldErrorPreference

    $responseText = ($response | Out-String)
    if (-not $exitCode -and $exitCode -ne 0) {
        $exitCode = 1
    }

    return [pscustomobject]@{
        ExitCode   = $exitCode
        OutputText = $responseText
    }
}

function Ensure-OutputFile {
    param(
        [string]$RequestedFile,
        [string]$AgentName,
        [string]$ScriptRoot
    )

    if ($RequestedFile) {
        return $RequestedFile
    }

    $logsDir = Join-Path $ScriptRoot "logs"
    if (-not (Test-Path -Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir | Out-Null
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Join-Path $logsDir "$AgentName-$stamp.log"
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

function Resolve-RepoRoot {
    param(
        [string]$RequestedRepoRoot,
        [string]$ScriptRoot
    )

    if ($RequestedRepoRoot) {
        return (Resolve-Path -Path $RequestedRepoRoot).Path
    }

    $currentPath = (Get-Location).Path
    if (Test-Path -Path (Join-Path $currentPath ".git")) {
        return $currentPath
    }

    return (Resolve-Path -Path (Join-Path $ScriptRoot "..\..")).Path
}

$profiles = Get-AgentProfiles
$profile = $profiles[$Agent]

if (-not $profile) {
    throw "Unknown agent '$Agent'."
}

$taskPath = (Resolve-Path -Path $TaskFile).Path
$taskBody = Get-Content -Path $taskPath -Raw
$repoRoot = Resolve-RepoRoot -RequestedRepoRoot $RepoRoot -ScriptRoot $scriptRoot
$scopeText = Resolve-ScopeText -RepoRoot $repoRoot -RequestedScopeFile $ProjectScopeFile

$prompt = New-AgentPrompt -Profile $profile -RepoRoot $repoRoot -TaskPath $taskPath -TaskBody $taskBody -ScopeText $scopeText -RequiredBranch $RequiredBranch -RequireStagedChanges $RequireStagedChanges.IsPresent

if ($DryRun) {
    Write-Output "=== Dry Run Prompt ==="
    Write-Output $prompt
    exit 0
}

$outputPath = Ensure-OutputFile -RequestedFile $OutputFile -AgentName $Agent -ScriptRoot $scriptRoot

if ($profile.Provider -eq "claude") {
    $result = Invoke-Model -ToolName "Claude" -Executable $ClaudeExecutable -Args $ClaudeArgs -Prompt $prompt
    Set-Content -Path $outputPath -Value $result.OutputText -NoNewline
    Write-Output $result.OutputText
    if ($result.ExitCode -ne 0) {
        throw "Claude execution failed with exit code $($result.ExitCode)."
    }
    Write-Output ""
    Write-Output "Saved output to: $outputPath"
    exit 0
}

if ($profile.Provider -eq "codex") {
    $result = Invoke-Model -ToolName "Codex" -Executable $CodexExecutable -Args $CodexArgs -Prompt $prompt
    Set-Content -Path $outputPath -Value $result.OutputText -NoNewline
    Write-Output $result.OutputText
    if ($result.ExitCode -ne 0) {
        throw "Codex execution failed with exit code $($result.ExitCode)."
    }
    Write-Output ""
    Write-Output "Saved output to: $outputPath"
    exit 0
}

Set-Content -Path $outputPath -Value $prompt -NoNewline
Write-Output "Agent '$Agent' is configured for prompt-only execution."
Write-Output "Prompt saved to: $outputPath"
