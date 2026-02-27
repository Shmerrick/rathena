# RESTART Project Scope (Authoritative)

This file defines the authoritative scope and decision rules for the RESTART fork project.
All agents must follow this before proposing or implementing any changes.

## Project Mission

- Build a private server fork with major game-system overhauls.
- Primary overhaul domains:
  - Combat system
  - Item system

## Gameplay Direction

- Base world/combat model: Renewal.
- Item model: RESTART-style random effect generation.
- Planned hybrid changes:
  - Apply pre-renewal stat breakpoint bonuses.
  - Remove status effect immunities.
  - Limit class progression to transcendent and 2nd job caps (no higher-tier job progression for players).

## Upstream Policy

- Upstream source allowed: `rathena/master` only.
- No upstream intake from any non-master branch.
- Upstream sync trigger: manual only.
- Conflict resolution default: RESTART fork behavior wins.
- Upstream sync must include deep investigation before integration.
- Finalized sync model: integration-branch merge workflow (`A2`), not direct rebase.

## Branching Policy

- Main working branch name: `RESTART`.
- Upstream integration branch: `RESTART-INTEGRATION`.
- Sync flow:
  - Merge `upstream/master` into `RESTART-INTEGRATION`.
  - Run full validations.
  - Promote to `RESTART` only after owner approval.

## Layering Policy

- Finalized layering model: `B1`.
- Keep custom systems isolated behind RESTART-owned modules/hooks where possible.
- Prefer extension points and wrappers over in-place upstream edits to reduce sync conflicts.
- Any unavoidable in-place edits must include notes explaining why hook/module isolation was not viable.

## Database Policy

- Database model is expected to diverge significantly from upstream.
- Required for DB changes:
  - Versioned migrations
  - Rollback scripts
  - Backward/forward compatibility notes

## Validation Policy

- Validation requirement level: everything relevant must be tested.
- Generic regression tests must be implemented and maintained across all major systems.
- Pre/post patch verification must detect any deviation from expected values.

## Arbitration Policy

- Arbiter is required to evaluate codex and claude outputs objectively.
- Arbiter may:
  - choose `codex`
  - choose `claude`
  - fuse both solutions if fusion is objectively better
- Arbitration output must include explicit rationale and tradeoffs.

## Change Approval Policy

- All high-risk decisions require owner approval by the user only.
- Agents must present multiple path options for high-risk events.
- Each option must include:
  - Positive repercussions
  - Negative repercussions
  - Cross-system impact analysis

## Security/Secrets Notes

- Private feature branches are not required right now.
- Secret handling and encrypted packet/channel strategy will be needed later (for anti-bot and related protections).
- When security-sensitive work starts, agents must require explicit owner approval and provide threat-model notes.

## Legal/Distribution Constraints

- No additional legal/licensing constraints were provided beyond existing upstream license terms.
