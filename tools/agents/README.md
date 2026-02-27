# Agent Operations

This directory contains the executable framework for managing project work through agents.

## Files

- `prompty.ps1`: Main dispatcher for agent tasks.
- `prompty.cmd`: Command Prompt wrapper for `prompty.ps1`.
- `parallel-judge.ps1`: Runs codex + claude in parallel, then judges winner.
- `parallel-judge.cmd`: Command Prompt wrapper for `parallel-judge.ps1`.
- `PROJECT_SCOPE.md`: Authoritative project scope and governance rules for all agents.
- `UPSTREAM_SYNC_RUNBOOK.md`: Manual sync runbook for `RESTART` and `RESTART-INTEGRATION`.
- `sync-restart-from-upstream.ps1`: Scripted upstream sync workflow.
- `sync-restart-from-upstream.cmd`: Command Prompt wrapper for sync workflow.
- `tasks/`: Task definitions.
- `logs/`: Captured output from agent runs.

## Quick Start

1. Create a task from template:

```powershell
Copy-Item tools/agents/tasks/TASK_TEMPLATE.md tools/agents/tasks/TASK-0001.md
```

2. Fill in task metadata and acceptance criteria.
3. Update `tools/agents/PROJECT_SCOPE.md` when strategic scope or policy changes.

4. Run Claude as a software developer:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/prompty.ps1 -Agent claude -TaskFile tools/agents/tasks/TASK-0001.md
```

5. Review output in console and `tools/agents/logs/`.

## Parallel Dev + Selection

Run codex and claude in parallel and have an arbiter select the solution to push forward:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/parallel-judge.ps1 -TaskFile tools/agents/tasks/TASK-0001.md
```

The run produces three artifacts in `tools/agents/logs/`:

- codex output
- claude output
- arbitration decision

Use prompt-only judge mode if you want to review arbitration manually:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/parallel-judge.ps1 -TaskFile tools/agents/tasks/TASK-0001.md -JudgeProvider prompt_only
```

By default, a non-zero exit from either candidate stops the run. To force arbitration even with failed candidates:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/parallel-judge.ps1 -TaskFile tools/agents/tasks/TASK-0001.md -AllowFailedCandidates
```

## Upstream Sync (A2)

Runbook: `tools/agents/UPSTREAM_SYNC_RUNBOOK.md`

Scripted sync:

```powershell
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File tools/agents/sync-restart-from-upstream.ps1 `
  -CreateUpstreamRemote `
  -Promote `
  -AllowUntrackedChanges `
  -ValidationCommands "cmake --build . --config Release" "ctest --output-on-failure -C Release"
```

Dry run:

```powershell
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File tools/agents/sync-restart-from-upstream.ps1 `
  -CreateUpstreamRemote `
  -Promote `
  -AllowUntrackedChanges `
  -ValidationCommands "cmake --build . --config Release" `
  -DryRun
```

If PowerShell argument parsing makes multi-command arrays awkward, use packed validation commands:

```powershell
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File tools/agents/sync-restart-from-upstream.ps1 `
  -CreateUpstreamRemote `
  -ValidationCommandPack "cmake --build out/build/x64-Debug --config Debug||ctest --test-dir out/build/x64-Debug --output-on-failure -C Debug"
```

## Claude CLI Notes

`prompty.ps1` defaults to:

```text
<generated prompt> | claude -p
```

If your local CLI uses different flags:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/prompty.ps1 -Agent claude -TaskFile tools/agents/tasks/TASK-0001.md -ClaudeExecutable claude -ClaudeArgs --print
```

## Codex CLI Notes

`prompty.ps1` defaults to:

```text
<generated prompt> | codex.cmd exec
```

If your local Codex executable differs:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/prompty.ps1 -Agent codex -TaskFile tools/agents/tasks/TASK-0001.md -CodexExecutable codex.cmd -CodexArgs exec
```

## Dry Run

Use `-DryRun` to inspect the generated prompt without calling a model:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/prompty.ps1 -Agent claude -TaskFile tools/agents/tasks/TASK-0001.md -DryRun
```
