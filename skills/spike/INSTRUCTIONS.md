# Spike Skill — Detailed Instructions

## Stage 02: Investigation

### Input
- `01-question/question.md` — the question being investigated
- `01-question/success-criteria.md` — what a good answer looks like
- Linked repo(s), web search

### Process

**Do not form opinions yet.** Gather facts.

Codebase investigation:
- Search for existing solutions to this problem in the codebase
- Find related prior art (ADRs, design docs, previous attempts)
- Identify constraints (what the answer must be compatible with)

External research:
- Search for libraries, standards, case studies relevant to the question
- Look for known failure modes (post-mortems, articles)
- Cite every source

Write two files:
- `02-investigation/codebase-findings.md` — what exists internally
- `02-investigation/external-research.md` — what exists externally

## Stage 03: Findings

### Input
- Both `02-investigation/` files

### Process

Synthesize what you found into `03-findings/findings.md`:
- What did you learn that's relevant to the question?
- What options exist? (enumerate them — at least 2)
- What are the trade-offs of each option?

Write `03-findings/options.md`:
- One section per option
- Pros, cons, effort estimate, risk level

## Stage 04: Recommendation

### Input
- All investigation and findings files
- `01-question/success-criteria.md`

### Process

Write `04-recommendation/recommendation.md`. It MUST contain:
- **Decision**: one of `ACCEPT` / `REJECT` / `DEFER`
  - ACCEPT: proceed with option X, here is why
  - REJECT: do not pursue this, here is why
  - DEFER: revisit when [specific condition] — not "when we have more time"
- **Rationale**: 2-3 paragraphs explaining the decision
- **Next steps**: if ACCEPT — what is the first concrete action?
- **Risks**: what could invalidate this recommendation?

A recommendation without a clear ACCEPT/REJECT/DEFER verdict fails the hard gate.
"It depends" is not a verdict.
