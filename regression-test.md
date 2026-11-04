---
name: regression-test
description: Generate a regression test that proves a fix by enforcing a strict Red-to-Green cycle (failing before the fix, passing after). Use when the user runs `/regression-test`, or asks to "write a test that proves this fix".
author: John Anthony Mariquit <john@mariquit.com>
license: MIT
metadata:
  copyright: Copyright (c) 2026 John Anthony Mariquit <john@mariquit.com>
---


# Prove the test breaks without the fix

A regression test that passes on fixed code is only half-proven. If it does not fail on the unfixed code, it may be testing a trivial happy path, mocking out the failure, or asserting on the wrong condition.

This skill enforces a **strict Red-to-Green execution cycle**: write the test, prove it turns red against the reverted fix, then re-apply the fix to watch it turn green.

---

## Procedure

### 0. Load Context
If `GLOSSARY.md` exists at the repo root, read it so test names and interface vocabulary match the project's domain language.

### 1. Isolate the Fix Diff
Capture the fix as a patch in the session scratchpad (not `/tmp`):
```bash
# Uncommitted fix
git diff > <scratchpad>/bugfix.patch

# Committed fix (replace <sha>, or use <base>..<head> for a multi-commit fix)
git show <sha> > <scratchpad>/bugfix.patch
```
If there is no fix diff, stop: there is nothing to prove.

### 2. Write the Targeted Regression Test

Write a minimal test that targets the reported bug symptom.

* **Declare the seam.** Name the public interface the test exercises and note in one line what it catches and what it misses. This is a note in the proof, not a confirmation gate, unless the seam is genuinely ambiguous.
* **Mock only at system boundaries.** Mock external APIs (payment, email, etc.), time/randomness, and sometimes the database or file system. Do not mock your own classes or modules, internal collaborators, or anything you control. Test the real interaction that failed, not a mock that bypasses the defect.
* **Design boundaries for mockability.** If the failing path touches an external client, inject it rather than constructing it internally. Prefer specific SDK-style functions (`getUser`, `createOrder`) over one generic fetcher with conditional logic, so each mock returns one shape.
* **Avoid implementation coupling.** Do not test private methods, and do not verify through a side channel (e.g., querying the database directly instead of using the interface). The tell: the test breaks on refactor while behavior is unchanged.
* **Avoid tautological assertions.** Expected values must come from an independent source: a known-good literal, a worked example, or the spec. Never recompute the expected value the way the code does, since that passes by construction.
* **Assertion sharpness.** Assert on the exact failure condition (specific error class, exact return value, or state transition), not generic truthiness such as `expect(result).toBeDefined()`.

### 3. The Red Phase (Execution 1)

Revert the fix:
```bash
git apply -R <scratchpad>/bugfix.patch
```
Use `git apply -R`, not `git checkout -- <files>`. Checkout discards every uncommitted change in those files, including unrelated work. Run the new test command.

* **If the test PASSES:** The test is invalid; it does not reproduce the bug. Refine or rewrite it until it fails with the exact reported symptom.
* **If the test FAILS for the reported symptom:** Record the failure output.
* **If the test FAILS for any other reason** (compile or import error, broken fixture, setup exception): That is not a Red. Fix the test harness and rerun the Red phase. Only the reported symptom counts.

### 4. The Green Phase (Execution 2)

Re-apply the fix:
```bash
git apply <scratchpad>/bugfix.patch
```
If the apply fails, stop and report. Do not continue on a half-reverted tree. Confirm with `git status` that the fixed files are modified again, then run the test command.

* **If the test PASSES:** The fix is proven.
* **If the test FAILS:** The fix is incomplete or breaks the newly written test.

### 5. Loop Discipline

Red → Green is not the place for cleanup. Do not refactor the fix or the test during the cycle, and make only the changes needed to pass. Refactoring belongs in review, after Green.

---

## Proof Template

```markdown
### Regression Test Proof

#### Test File
`<path/to/test_file>`

#### Seam
`<public interface exercised>`: catches `<behavior>`, misses `<behavior>`.

#### Red-to-Green Verification Log

1. **RED Phase (Without Fix):**
   - *Command:* `<test command run>`
   - *Result:* **FAILED** (as expected)
   - *Output:* `<exact error message or failing assertion>`
   - *Failure matches reported symptom:* yes

2. **GREEN Phase (With Fix Applied):**
   - *Command:* `<test command run>`
   - *Result:* **PASSED**
   - *Duration:* `<execution time>`

#### Proof Verdict
The regression test strictly reproduces the defect when the fix is removed and passes when applied.
```

---

## Checklist

* [ ] `GLOSSARY.md` read if present
* [ ] Fix captured as a patch in the scratchpad (uncommitted or committed)
* [ ] Seam declared, with what it catches and misses
* [ ] Only system boundaries mocked; no implementation-coupled or tautological assertions
* [ ] Minimal regression test created with sharp assertions
* [ ] Fix reverted with `git apply -R`
* [ ] Test executed against unfixed code and FAILED (Red)
* [ ] Red failure matches the reported symptom, not a compile or setup error
* [ ] Fix re-applied cleanly and `git status` verified
* [ ] Test executed with the fix applied and PASSED (Green)
