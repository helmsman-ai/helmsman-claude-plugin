# Helmsman Agent Reference

Helmsman uses six specialist agents. The Orchestrator coordinates them — you never
invoke agents directly; you interact through commands (`/approve`, `/comment`, `/advance`).

> **Note on git push:** No agent pushes to a remote. The Implementer commits code
> to the local project branch (`helmsman/<project-name>`); pushing is always a
> manual developer action. The `pre-push-guard.sh` hook can warn or block a push
> if the project hasn't reached the right stage, but it never initiates one.
> This keeps the launch decision in your hands.

---

## Orchestrator

**Role:** Central coordinator. Reads `state.yaml`, routes work to the right agent,
enforces gates, writes all state transitions, and logs decisions.

**Runs at:** Every command (`/start-project`, `/advance`, `/approve`, `/comment`, etc.)

**Reads:** `state.yaml`, `manifest.yaml`, `decisions.log.md`, current-stage artifacts

**Produces:** `state.yaml` updates, `decisions.log.md` entries, status messages to you

**How to interact:**
- You never talk to the Orchestrator about implementation details — it coordinates, it doesn't design or code.
- If the Orchestrator seems stuck or confused about state, run `/status` to see what it thinks the current state is.
- The Orchestrator is the **only writer of `state.yaml`** — never edit it manually.

---

## PRD Reviewer

**Role:** Skeptical senior engineer who turns your raw PRD into an implementable specification. Finds gaps, inconsistencies, and hidden assumptions before they become bugs.

**Runs at:** Stage 02 (`02-prd-clean`) — feature, refactor, spike, experiment modes

**Reads:** `01-prd/input.md` (your raw PRD), repo memory, project memory

**Produces (all in `02-prd-clean/`):**
- `clean-prd.md` — the implementation-ready PRD
- `assumptions.md` — things treated as true without explicit confirmation
- `risks.md` — identified risks
- `open-questions.md` — gaps requiring your input
- `out-of-scope.md` — what was explicitly excluded

**How to interact:**
- Use `/comment "..."` to answer open questions or push back on assumptions.
- If the clean PRD misunderstood your intent, use `/comment` to clarify — the agent will revise.
- Use `/approve` when the clean PRD accurately reflects what you want to build.

---

## Researcher

**Role:** Investigative engineer who maps the codebase before any design work begins. Finds what already exists, who the stakeholders are, and what dependencies are involved.

**Runs at:** Stage 03 (`03-discovery`) in feature mode; Stage 02 in bugfix (`02-reproduce`); various investigation stages in spike, experiment, refactor

**Reads:** Clean PRD artifacts, linked repo paths (from `manifest.yaml`), repo memory

**Produces (all in `03-discovery/`):**
- `codebase-findings.md` — existing services, patterns, and similar features relevant to the PRD
- `stakeholder-map.md` — teams and systems impacted
- `dependencies.md` — external systems, APIs, libraries involved
- `prior-art.md` — past similar work in the codebase
- `open-questions.md` — remaining unknowns that need resolution

**How to interact:**
- If the Researcher missed a service or file, use `/comment` to point it out.
- The Researcher does **not** make architecture recommendations — that's the Architect's job. If findings look like design choices, push back.
- Use `/approve` when the discovery picture looks complete.

---

## Architect

**Role:** Pragmatic designer who evaluates at least two alternatives before committing to an approach, records ADRs, then breaks the approved design into atomic implementation tasks.

**Runs at:** Stage 04 (`04-tech-design`) and Stage 05 (`05-tasks`) in feature/refactor modes; Stage 03 (`03-fix-plan`) in bugfix; Stage 02 (`02-design`) in experiment

**Reads:** Clean PRD, discovery findings, repo memory, project memory

**Produces (Stage 04, all in `04-tech-design/`):**
- `design.md` — full technical design
- `alternatives.md` — evaluated alternatives with trade-offs
- `adrs/` — Architecture Decision Records

**Produces (Stage 05, all in `05-tasks/`):**
- `task-index.md` — ordered list of all tasks
- `NNN-<slug>.md` — one file per atomic task, with acceptance criteria

**How to interact:**
- If you prefer a different alternative than the one the Architect chose, use `/comment "I prefer approach B because..."`.
- If a task in the breakdown is too large or unclear, use `/comment` on Stage 05 before approving.
- The Architect must show at least 2 alternatives (hard gate `has_2_alternatives`). If only one approach is documented, the gate will block.

---

## Implementer

**Role:** Disciplined coder who implements one task at a time: writes tests, follows conventions, commits with structured messages, updates the progress log.

**Runs at:** Stage 06 (`06-implementation`) in feature/bugfix/refactor/experiment/chore/hotfix modes — invoked once per task.

**Reads:** One task file (`05-tasks/NNN-<slug>.md`), repo memory, `progress.md`

**Produces:**
- Code commits to the project's branch (`helmsman/<project-name>`)
- `06-implementation/progress.md` — updated after each task
- `06-implementation/task-notes/NNN-<slug>.md` — notes for the Reviewer

**How to interact:**
- The Implementer works one task at a time. If a task is too broad, it should have been caught at Stage 05 — use `/jump-back 05-tasks` to fix it.
- If the Implementer misunderstood a task requirement, use `/comment` to clarify.
- The Implementer does **not** read other task files or project history — it only knows its assigned task. Keep task files self-contained.

---

## Reviewer

**Role:** Picky senior engineer who checks each implemented task against its acceptance criteria, conventions, security requirements, and edge cases. Produces a severity-rated review report.

**Runs at:** Stage 07 (`07-review`) — invoked once per completed task.

**Reads:** Task spec, Implementer's task notes, relevant code diff, repo memory

**Produces:** `07-review/self-review-NNN-<slug>.md` — structured report with severity-rated issues

**How to interact:**
- Review the report; use `/comment` to dispute a finding or ask for clarification.
- If the Reviewer finds a critical issue, the `no_critical_issues` hard gate will block `/advance`. The Implementer must address it first.
- The Reviewer does **not** fix issues — it only finds them. Fixes go back to the Implementer.
