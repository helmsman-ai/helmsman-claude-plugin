# Choosing a Helmsman Mode

> Quick guide: answer three questions, pick the right mode.

---

## Decision Tree

**1. Is this an emergency — production broken, every minute costs?**
→ Yes → **hotfix**
→ No → continue

**2. Will this produce production-ready code?**
→ No (investigating, exploring, deciding) → **spike**
→ Yes, but only if a hypothesis is confirmed → **experiment**
→ Yes → continue

**3. What kind of code change is it?**

| Change type | Mode |
|---|---|
| New feature or significant new behavior | **feature** |
| Fix a known, confirmed bug | **bugfix** |
| Restructure existing code, behavior unchanged | **refactor** |
| Dependency bump, config, tooling | **chore** |

---

## Mode Comparison

| Mode | Stages | Has Design | Has Research | Code? | Fast Track |
|---|---|---|---|---|---|
| feature | 9 | ✅ full | ✅ full | ✅ | ❌ |
| bugfix | 6 | ✅ light | ✅ | ✅ | ❌ |
| refactor | 7 | ✅ full | ✅ | ✅ | ❌ |
| spike | 5 | ❌ | ✅ | ❌ | ❌ |
| experiment | 6 | ✅ light | ✅ | ✅ | ❌ |
| hotfix | 4 | ❌ | ❌ | ✅ | ✅ ⚡ |
| chore | 4 | ❌ | ❌ | ✅ | ❌ |

---

## When You're Unsure

**"Is this a bug or a feature request?"**
If users can accomplish their goal through another path → it's a bug.
If there is no other path → it's a missing feature. Use feature mode.

**"Should I refactor or just fix the bug?"**
Fix the bug first (bugfix mode). Then refactor separately (refactor mode).
Never do both in one project — the PR becomes impossible to review.

**"Is this investigation a spike or an experiment?"**
Spike: you need an answer to a *question* before building.
Experiment: you need to *build something* to get the answer.

**"This chore got more complex — should I switch modes?"**
Yes. Stop the chore project. Start a new refactor or feature project.
Chore mode has no design stage — if the work needs design, it's not a chore.
