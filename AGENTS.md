# Agents Framework for rAthena

This framework defines how autonomous or semi-autonomous agents manage work in this repository.

## Objectives

- Keep project work traceable through explicit task files.
- Separate planning, implementation, review, and release responsibilities.
- Support multiple developer agents, including Claude, with a consistent workflow.

## Directory Layout

- `tools/agents/prompty.ps1`: Task dispatcher and agent runner.
- `tools/agents/prompty.cmd`: Command Prompt wrapper for `prompty.ps1`.
- `tools/agents/parallel-judge.ps1`: Parallel codex/claude execution plus arbitration.
- `tools/agents/parallel-judge.cmd`: Command Prompt wrapper for `parallel-judge.ps1`.
- `tools/agents/PROJECT_SCOPE.md`: Authoritative project scope and decision policies.
- `tools/agents/UPSTREAM_SYNC_RUNBOOK.md`: Approved manual upstream sync workflow.
- `tools/agents/sync-restart-from-upstream.ps1`: Scripted RESTART integration-branch sync.
- `tools/agents/sync-restart-from-upstream.cmd`: Command Prompt wrapper for sync script.
- `tools/agents/tasks/`: Task files managed by agents.
- `tools/agents/tasks/TASK_TEMPLATE.md`: Template for new tasks.
- `tools/agents/logs/`: Run logs and model responses.

## Mandatory Context

Before planning or implementation, agents must load and comply with:

- `AGENTS.md`
- `tools/agents/PROJECT_SCOPE.md`

## Agent Registry

- `architect`: Defines implementation plans, risk notes, and sequencing.
- `codex`: Software developer focused on implementation and repo edits.
- `claude`: Software developer focused on implementation and repo edits.
- `arbiter`: Decision agent that selects the candidate solution to move forward.
- `qa`: Verification agent focused on test coverage and regressions.
- `release`: Final packaging, changelog checks, and handoff readiness.

Claude is a first-class software developer in this framework and can be executed through `prompty`.

## Task Lifecycle

Use these states in task files:

`BACKLOG -> READY -> IN_PROGRESS -> REVIEW -> DONE`

Parallel development lane:

`READY -> PARALLEL_DEV -> ARBITRATION -> REVIEW -> DONE`

Optional terminal state:

`BLOCKED`

Rules:

- Every task has exactly one current owner.
- Every completion must include verification commands and outcomes.
- `REVIEW` requires a different agent from the implementer when possible.
- In `PARALLEL_DEV`, codex and claude are co-owners until arbitration is complete.
- In `PARALLEL_DEV`, codex and claude must each submit staged file changes on their own agent branch before arbitration.
- Arbitration decisions should be made only from successful candidate runs unless explicitly overridden.

## Task File Contract

All tasks in `tools/agents/tasks/` should follow `TASK_TEMPLATE.md` and include:

- Task metadata (ID, title, status, owner, priority).
- Scope and non-goals.
- Acceptance criteria.
- Execution log (commands run, checks performed, files changed).

## Execution via prompty

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/prompty.ps1 -Agent claude -TaskFile tools/agents/tasks/TASK-0001.md
```

Command Prompt:

```cmd
tools\agents\prompty.cmd -Agent claude -TaskFile tools\agents\tasks\TASK-0001.md
```

Dry run (show final prompt without invoking a model):

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/prompty.ps1 -Agent claude -TaskFile tools/agents/tasks/TASK-0001.md -DryRun
```

Parallel codex + claude run with automatic arbitration:

```powershell
powershell -ExecutionPolicy Bypass -File tools/agents/parallel-judge.ps1 -TaskFile tools/agents/tasks/TASK-0001.md
```

Behavior:

- Creates isolated per-agent branches/worktrees for `codex` and `claude`.
- Waits for both coding agents to finish and stage their changes.
- Arbitration proceeds only after both candidate runs return.

Command Prompt:

```cmd
tools\agents\parallel-judge.cmd -TaskFile tools\agents\tasks\TASK-0001.md
```

## Definition of Done

A task is `DONE` only when:

- Acceptance criteria are met.
- Relevant build/test commands are documented in the task execution log.
- Risks and follow-up work are recorded.

## Guardrails

- Keep commits focused to a single task unless explicitly grouped.
- Do not mix release operations with feature implementation in one task.
- Escalate unclear requirements by moving task status to `BLOCKED` with a concrete question.
