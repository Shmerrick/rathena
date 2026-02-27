# RESTART Upstream Sync Runbook

This runbook implements the approved sync model:

- `A2`: merge via integration branch
- `B1`: layered custom logic via RESTART-owned modules/hooks

## Branch and Remote Model

- Working branch: `RESTART`
- Integration branch: `RESTART-INTEGRATION`
- Upstream remote: `upstream` (points to official `rathena`)
- Allowed intake branch: `upstream/master` only

## One-Time Setup

```powershell
git remote add upstream https://github.com/rathena/rathena.git
git fetch upstream master
```

Create `RESTART` once if missing:

```powershell
git checkout -b RESTART origin/master
```

## Standard Manual Sync

Use the script:

```powershell
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File tools/agents/sync-restart-from-upstream.ps1 `
  -CreateUpstreamRemote `
  -Promote `
  -AllowUntrackedChanges `
  -ValidationCommands "cmake --build . --config Release" "ctest --output-on-failure -C Release"
```

What it does:

1. Verifies clean working tree.
2. Ensures `upstream` remote exists (creates it when `-CreateUpstreamRemote` is set).
3. Fetches `upstream/master`.
4. Resets `RESTART-INTEGRATION` to `RESTART`.
5. Merges `upstream/master` into `RESTART-INTEGRATION`.
6. Runs provided validation commands.
7. Promotes result to `RESTART` (with `-Promote`).

Note:

- Use `-AllowUntrackedChanges` if your working tree has untracked-only files (for example local agent docs/scripts).
- Build/test tooling (`cmake`, `ctest`, `msbuild`) must exist in PATH for build validations.

## Conflict Handling

1. Resolve conflicts on `RESTART-INTEGRATION`.
2. Keep RESTART system behavior as the default outcome where conflicts occur.
3. Re-run full validation suite.
4. Request explicit owner approval for high-risk conflict resolutions.

## High-Risk Gate

Any high-risk sync impact must include:

- At least 2 path options
- Positive and negative repercussions per option
- Cross-system impact notes

Only the owner can approve final high-risk path selection.

## Layering Guardrails

- Add/extend RESTART code in dedicated modules/hooks first.
- Avoid scattering direct edits across upstream core unless no extension point exists.
- For unavoidable direct edits, add a short rationale note in the task execution log.
