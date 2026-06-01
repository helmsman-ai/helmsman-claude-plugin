# Decision Log — {{project_name}}

> **Append-only** — entries are never edited or deleted.
> The Orchestrator appends an entry after every significant action.
> For the compiled summary, see `dossier.md`.

---

## {{date}} — Project started

Mode: {{mode}} | Linked repos: {{repos}} | Started by: {{user}}

---

<!-- ──────────────────────────────────────────────────────────────────────
     ENTRY TEMPLATE (copy-paste when adding manually):

## {{YYYY-MM-DD HH:MM}} — {{action_title}}

Stage: {{stage}}
Action: approved | advanced | commented | jumped_back | skipped | gate_failed | gate_overridden
       | propagation_started | propagation_stage_approved | propagation_stage_rejected
       | propagation_aborted | snapshot_created | snapshot_restored | cir_produced | cir_acknowledged

{{narrative: what happened and why, 2-5 sentences}}

Key decisions:
  - {{decision_1}}
  - {{decision_2}}

Artifacts affected:
  - {{artifact_path}}: {{change_summary}}

────────────────────────────────────────────────────────────────────── -->

## {{date}} — PRD Clean approved

Stage: 02-prd-clean
Action: approved

{{summary_of_key_clarifications}}

Key decisions:
  - {{decision}}

Open questions remaining:
  - {{question}} — owner: {{owner}}

---

## {{date}} — Architecture decision: {{decision_title}}

Stage: 04-tech-design
Action: approved

{{rationale_summary}}

Key decisions:
  - Chose {{option}} over {{alternative}} — {{one_line_reason}}

ADR: `04-tech-design/adrs/{{number}}-{{slug}}.md`

---

## {{date}} — Implementation complete: Task {{number}}

Stage: 06-implementation
Action: approved

Task: [{{number}} — {{title}}](05-tasks/{{number}}-{{slug}}.md)
Commit: `{{sha}}`

Notes: {{implementation_notes}}

---

## {{YYYY-MM-DD HH:MM}} — Jump-back to {{target_stage}}

Stage: {{target_stage}}
Action: jumped_back

User jumped back from Stage {{from_stage}} to Stage {{target_stage}}. Reason: {{reason}}.
The following stages are now stale and will be re-run by /propagate: {{stale_stages_list}}.
No artifact files were deleted or modified.
{{If --force was used: "Note: --force flag used; stage {{in_progress_stage}} was in-progress at time of jump-back."}}

Key decisions:
  - Jumped back to {{target_stage}}: {{reason}}

Artifacts affected:
  - state.yaml: current_stage = {{target_stage}}; stale_stages = [{{list}}]

---

## {{YYYY-MM-DD HH:MM}} — Propagation started

Stage: {{first_stale_stage}}
Action: propagation_started

Propagation initiated. Stale stages to process in order: {{stale_stages_list}}.
Reason for original jump-back: {{jump_back_reason}}.

---

## {{YYYY-MM-DD HH:MM}} — Propagation approved: {{stage_label}}

Stage: {{stage_id}}
Action: propagation_stage_approved

User approved the re-run of Stage {{N}} ({{label}}) during propagation.
Snapshot: {{snapshot_id}}. Diff: {{diff_path}}.

Key decisions:
  - Accepted propagated version of {{stage_id}} over snapshot

Artifacts affected:
  - {{stage_dir}}/{{file}}: updated by propagation re-run

---

## {{YYYY-MM-DD HH:MM}} — Propagation rejected: {{stage_label}}

Stage: {{stage_id}}
Action: propagation_stage_rejected

User rejected the re-run of Stage {{N}} ({{label}}). Snapshot {{snapshot_id}} restored.
Stage remains stale. User will edit artifacts manually or re-run /propagate.

Artifacts affected:
  - {{stage_dir}}/{{file}}: restored from snapshot

---

## {{YYYY-MM-DD HH:MM}} — Propagation aborted

Stage: {{first_stale_stage}}
Action: propagation_aborted

User ran /propagate --abort. Snapshots restored for all re-run stages: {{restored_list}}.
Stale stages remain stale.

Artifacts affected:
  - {{stage_dir}}/: restored from snapshot for each stage listed above

---

## {{YYYY-MM-DD HH:MM}} — Change Impact Report produced

Stage: {{impl_stage}}
Action: cir_produced

Change Impact Report generated for the implementation stage after upstream propagation.
Report: {{impl_stage}}/change-impact-report.md

Summary:
  - leave: {{N}} tasks
  - amend: {{N}} tasks
  - redo: {{N}} tasks

---

## {{YYYY-MM-DD HH:MM}} — Change Impact Report acknowledged

Stage: {{impl_stage}}
Action: cir_acknowledged

User acknowledged the Change Impact Report. Implementation stage removed from stale list.
Propagation complete. Pipeline can resume with /advance.

---

## {{YYYY-MM-DD HH:MM}} — Snapshot created: {{stage_label}}

Stage: {{stage_id}}
Action: snapshot_created

Snapshot {{snapshot_id}} created before propagation re-run of Stage {{N}} ({{label}}).
Files captured: {{file_count}} files in {{stage_dir}}/.

Artifacts affected:
  - .snapshots/{{snapshot_id}}/MANIFEST.yaml: created
  - .snapshots/{{snapshot_id}}/files/: {{file_count}} files copied

---

## {{YYYY-MM-DD HH:MM}} — Snapshot restored: {{stage_label}}

Stage: {{stage_id}}
Action: snapshot_restored

User manually restored snapshot {{snapshot_id}} via /snapshots command (taken {{created_at}}, reason: {{reason}}).
Files in {{stage_dir}}/ reverted to snapshot state. Stage marked stale.

Artifacts affected:
  - {{stage_dir}}/{{file}}: restored from snapshot
