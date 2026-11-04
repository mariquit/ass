---
name: deconstruct
description: Distill how a problem was solved — the diagnostic path, dead ends, and the breakthrough observation — into a durable approach document. Use when the user runs `/deconstruct` or asks to "write down how we figured this out" / "capture this approach".
author: John Anthony Mariquit <john@mariquit.com>
license: MIT
metadata:
  copyright: Copyright (c) 2026 John Anthony Mariquit <john@mariquit.com>
---

# Extract the approach, not just the fix

A fix is already captured by the commit. What evaporates when the session
ends is *how the problem was solved*: which symptom pointed where, which
hypotheses were tried and killed, and what evidence finally discriminated.
That knowledge is what makes the next occurrence a ten-minute job instead of
a rediscovery. This skill mines the current session (or, second-best, the
git record) and writes that knowledge down while it is still fresh.

The test for every sentence you write: **would it still be useful if the fix
were different?** "Changed `flush()` to `sync_all()`" is the fix. "Data loss
on crash but not on clean exit means buffered writes reached the file but
not the disk — check durability calls before suspecting the write path" is
the approach. Capture the second kind.

## Sources, in order of trust

1. **The conversation you are in.** The real diagnostic path is here: the
   commands run, the outputs that surprised, the moment the hypothesis
   changed. This is the primary source — reconstruct from it, don't
   summarize from memory of your own conclusions.
2. **Git evidence.** `git log --oneline -10`, the fixing commit's diff, and
   any checkpoint trail. Use it to pin exact file paths, line numbers, and
   the commit sha the document should reference.
3. **Cold reconstruction** (skill invoked without a live session, e.g.
   pointed at a past commit or PR). Rebuild what you can from the diff and
   commit message, but mark the document `confidence: reconstructed` in its
   frontmatter — a reconstructed diagnostic path is a plausible story, not a
   record.

## Procedure

1. **Confirm there is an approach worth extracting.** One-line typo fixes
   and mechanical renames have no diagnostic path; say so and stop rather
   than padding a document. The signal that extraction is worth it: the
   session contained at least one wrong hypothesis, or the search space was
   non-obvious at the start.
2. **Walk the session backwards from the fix** and list, in order: the
   initial symptom (verbatim error text or observable behavior, not a
   paraphrase), each hypothesis in the order it was held, the specific
   command or observation that killed or confirmed it, and the single
   observation after which the cause was obvious.
3. **Name the reusable heuristic.** Compress the path into one or two
   "when you see X, check Y before Z" sentences. If you cannot state one,
   the diagnostic path was luck — record the path anyway and say the
   heuristic is unknown; do not invent one.
4. **Write the document** using the template below to
   `docs/approaches/<slug>.md`, where the slug names the *problem shape*,
   not the fix (`test-gate-green-locally-red-in-ci.md`, not
   `fix-path-handling.md`). Create `docs/approaches/` if it doesn't exist.
5. **Verify every concrete claim.** Each file path, command, field name, and
   commit sha in the document must exist right now — `grep`/`git show` each
   one, same standard as any other docs change in this repo.
6. **Propose promotion, don't self-promote.** If the lesson is a
   repo-specific pitfall others will hit, suggest a one-line addition to
   CLAUDE.md's "Mistakes you will make here" list; if it is a general
   technique independent of this repo, suggest a `feedback`-type memory.
   Surface the suggestion to the user — the approach document itself is the
   deliverable, the promotion is their call.

## Document template

```markdown
---
problem: <one line — the symptom, not the cause>
solved: <YYYY-MM-DD>
fix_commit: <sha, or "uncommitted">
confidence: session | reconstructed
---

# <Problem shape as a title>

## Symptom
Verbatim error output or observable behavior. What a person greps for when
it happens again — keep the exact strings.

## Diagnostic path
Ordered. Each step: what was checked, the command used, and what the result
ruled in or out. This section is the point of the document.

## Dead ends
Hypotheses held and abandoned, each with the evidence that killed it. A
reader hitting this symptom should be able to skip these entirely.

## Turning point
The single observation after which the cause was obvious.

## Fix
One or two lines plus the commit sha. The diff is the authority; don't
duplicate it.

## Reusable heuristic
"When you see X, check Y before Z." Omit the section rather than fabricate
one.

## Verification
How the fix was proven — the command that failed before and passed after.
```

## Checklist

- [ ] Symptom recorded verbatim, not paraphrased
- [ ] Diagnostic path reconstructed from the session/git record, in order
- [ ] Every dead end paired with the evidence that killed it
- [ ] Heuristic stated — or explicitly marked unknown, never invented
- [ ] All paths, commands, and shas in the document verified to exist
- [ ] Saved to `docs/approaches/<problem-shape-slug>.md`
- [ ] Promotion to CLAUDE.md, PLAN.md, PROGRESS.md or memory suggested where warranted, not applied
