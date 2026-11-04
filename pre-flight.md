---
name: pre-flight
description: Perform a pre-flight audit on local git changes covering blast radius (unseen ripple effects, broken implicit invariants, missing test surfaces), spec alignment (missing or unrequested behavior), and repo standards before creating a PR. Use when the user runs `/pre-flight` or asks to "audit these changes" / "check for breaking changes".
author: John Anthony Mariquit <john@mariquit.com>
license: MIT
metadata:
  copyright: Copyright (c) 2026 John Anthony Mariquit <john@mariquit.com>
---

# Trace the ripple effects, don't just read the diff

A code review tells you if the diff looks clean. A pre-flight audit tells you what broke outside the diff, and whether the diff does what was asked.

When signature types change, shared state is mutated, or async contracts shift, the primary breakage occurs in code that was *not* modified in the current branch. This skill audits the boundary between your diff and the rest of the codebase to expose unseen blast radius, then checks the diff against its spec and the repo's documented standards.

---

## Procedure

### 1. Identify the Diff Boundary
Pin the base ref: use the base branch the user names, otherwise `origin/main`. Run `git fetch origin` so the base isn't stale, then:
- `git rev-parse <base>` to confirm it resolves.
- `git diff <base>...HEAD --stat` to confirm the diff is non-empty.

Stop and report if either check fails. Don't audit a bad ref or an empty diff.

Then run `git diff <base>...HEAD --name-only` to list modified files, and `git diff -U0 <base>...HEAD` to isolate modified exports, public functions, types, schemas, and configurations. Run `git log <base>..HEAD --oneline` and keep the commit messages for step 3.

### 2. Audit the Blast Radius
For every modified interface or behavior, run `ripgrep` across the *unmodified* repository to map affected consumers:
- **Signature & Contract Changes:** Search for all call sites of renamed/modified functions. Verify argument order, optional parameters, and return type expectations.
- **Data & Schema Mutations:** If a database schema, serialization format, or API response payload changed, grep for references to those fields across readers, workers, and serialization layers.
- **Implicit Invariants:** Search for hidden assumptions (e.g., assuming a list is non-empty, assuming sync execution, assuming global singleton state) that the diff violates.

Structural smells, applied as judgement calls. Report one only when it points to a concrete ripple:
- **Shotgun Surgery:** One logical change touches many files in the diff. Grep for the shared concept and confirm every site was updated. A missed site is a ripple.
- **Duplicated Code:** The same logic appears in more than one place. If the diff changes one copy, grep for its twins in unmodified code and confirm they still agree.
- **Divergent Change:** A module in the diff changed for unrelated reasons. Each unrelated concern is a separate breakage surface, so list them.

### 3. Check Spec Alignment
Find the originating spec, in this order:
1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`).
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.

If none is found, ask the user once. If there isn't one, skip this step and say so in the report.

Check the diff against the spec:
- **Missing or partial:** A requirement the spec asks for that the diff doesn't fully deliver.
- **Scope creep:** Behavior in the diff the spec doesn't ask for.
- **Looks done, looks wrong:** A requirement that appears implemented but seems incorrect.

Quote the spec line for each finding.

### 4. Check for Silent Omissions and Repo Standards
Examine the change for required co-modifications:
- Did a DB schema change without an accompanying migration file?
- Did an endpoint or CLI flag change without updated documentation/types?
- Did a new conditional branch get added without a corresponding test path?

Find the repo's documented standards: `CONTRIBUTING.md`, `CODING_STANDARDS.md`, and any docs describing how changes should be made (changelog, API docs, migration rules). Each documented co-modification requirement becomes a check here. A documented repo standard overrides any general rule in this skill. Skip anything tooling already enforces.

### 5. Formulate the Risk Report
Report each axis separately: Blast Radius, Spec Alignment, Standards. Don't merge or rerank findings across axes. If an axis has no risks, say so in one sentence. Don't invent theoretical hazards.

End with one line per axis giving the finding count and the worst item in that axis. Don't pick a winner across axes.

---

## Report Template

```markdown
### Pre-Flight Audit

#### Summary
- **Base:** <ref> (resolved, diff non-empty)
- **Files Modified:** <Count>
- **Blast Radius:** [ LOW | MEDIUM | HIGH ]
- **Spec Alignment:** [ MATCH | PARTIAL | MISMATCH | NO SPEC ]
- **Standards:** [ PASS | FINDINGS | NO STANDARDS DOCS ]

#### Blast Radius (Outside Diff)
- `<File path>:<line>`: <Function/Type modified> is called here. Verify <specific invariant/argument expected>.

**Unhandled Edge Cases & Silent Risks**
1. **[Risk Category]:** <Description of broken assumption or missing handler>
   - *Impacted Area:* `<file or module>`
   - *Recommended Action:* <Concrete check or fix>

#### Spec Alignment
- **Missing/Partial:** <requirement> — "<quoted spec line>"
- **Scope Creep:** <behavior> at `<file>:<line>`
- **Looks Wrong:** <requirement> — "<quoted spec line>" — <why>

#### Standards
- `<standards doc>` § <rule>: <violation at file:line>

#### Test & Contract Coverage
- [ ] New/modified logic backed by direct tests
- [ ] External/API contracts updated where applicable
- [ ] No unhandled promise rejections / unpropagated errors introduced

#### Worst Per Axis
- **Blast Radius:** <item or "none">
- **Spec Alignment:** <item or "none">
- **Standards:** <item or "none">
```

---

## Checklist

* [ ] Base ref resolved and diff confirmed non-empty
* [ ] `git diff` parsed to extract altered interfaces and public signatures
* [ ] All consumers outside the diff checked via `ripgrep`
* [ ] Shotgun Surgery, Duplicated Code, and Divergent Change checked as judgement calls
* [ ] Diff checked against the originating spec (or skipped and noted)
* [ ] Schema, serialization, and migration integrity verified
* [ ] Repo standards docs checked for required co-modifications
* [ ] High-risk ripple effects highlighted with exact file paths and line numbers
