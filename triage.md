---
name: triage
description: Enforce structured, scientific debugging before modifying code. Formulate falsifiable hypotheses, test them with zero-mutation diagnostic commands, and isolate the root cause. Use when the user runs `/triage`, asks to "debug this systematically", or when facing a complex/hard-to-reproduce bug.
author: John Anthony Mariquit <john@mariquit.com>
license: MIT
metadata:
  copyright: Copyright (c) 2026 John Anthony Mariquit <john@mariquit.com>
---

# Prove the cause before touching the code

When faced with a bug, the default failure mode of an AI agent is to guess a fix, edit a file, and run tests to see if it worked. This churn creates messy git diffs, obscures the real defect, and wastes tokens.

This skill forces a **diagnostic freeze**. No application code may be edited until a hypothesis has been isolated by direct evidence and all competing hypotheses have been killed.

## The Rule of Falsification

A hypothesis is invalid if it cannot be proven wrong by a single observation. 

* **Bad Hypothesis:** "Maybe the async timing is weird." *(Not falsifiable)*
* **Good Hypothesis:** "The worker thread process exits before `flush_buffer()` resolves, dropping pending records." *(Falsifiable: log `flush_buffer()` completion timestamp vs. process exit timestamp)*

---

## Procedure

### 1. Formulate the Triad
Generate **exactly 3 distinct, mutually exclusive hypotheses** for the root cause. Seed them from common failure categories: check-then-write races, swallowed errors, writes in the wrong order, work repeated by every process, unbounded growth, a query per item, time zones, empty or zero inputs, and broken callers after a signature change. If the report could be documented or intended behavior, make one hypothesis "intended behavior" and kill it by reading the code comments, README, and tests. Each must specify:
- The assumed mechanism of failure.
- The precise observation/log that would **kill** it (rule it out).
- The precise observation/log that would **confirm** it (rule it in).

### 2. Design Zero-Mutation Diagnostics
For each hypothesis, formulate the minimum-cost, non-destructive check. 
* *Preferred:* `ripgrep` call site audits, reading log outputs, running an isolated query, inspecting environment state, or executing a single read-only CLI command.
* *Secondary:* Temporary inline log statements (must be marked `// TEMP_TRIAGE` for clean removal).
* *Forbidden:* Patching application logic or editing configuration files.
* *Load:* For scale, timing, or concurrency bugs, state the load, data size, or environment the bug needs to reproduce (for example, concurrent requests or large input) before running the check.

### 3. Execute and Eliminate
Run the diagnostic checks sequentially in order of lowest execution cost:
1. State which hypothesis is being tested and what output is expected.
2. Run the diagnostic command.
3. Mark the hypothesis **KILLED** or **CANDIDATE** based on raw output, not assumptions.
4. Verification gate: before a CANDIDATE is promoted to **CONFIRMED**, re-read the cited lines and confirm the trigger condition actually occurs (the caller exists, the value can really be empty, the code really runs). No re-check, no CONFIRMED.

### 4. Declare the Root Cause
Once 2 hypotheses are KILLED and 1 is CONFIRMED by direct observation, declare the diagnostic phase complete. Present the isolated root cause to the user alongside the confirming evidence before proceeding to write a fix.

Before writing any fix:
- Grep every caller of the defect site. If the cause sits in a shared function, the fix goes there, not in one caller.
- Propose the smallest fix that works, and state the cost of skipping it.
- Name the regression test that would have caught this bug. Write it only if the user asks.

---

## Output Template

```markdown
### Bug Triage Analysis

#### Symptom
<Verbatim behavior error failure or reproducible>

#### Hypotheses
1. **[H1 Name]:** <Falsifiable mechanism>
   - *Falsified by:* <Condition out rules that this>
   - *Status:* [ UNTESTED | KILLED | CONFIRMED ]
2. **[H2 Name]:** <Falsifiable mechanism>
   - *Falsified by:* <Condition out rules that this>
   - *Status:* [ UNTESTED | KILLED | CONFIRMED ]
3. **[H3 Name]:** <Falsifiable mechanism>
   - *Falsified by:* <Condition out rules that this>
   - *Status:* [ UNTESTED | KILLED | CONFIRMED ]

#### Diagnostic Trail
- **Testing H1:** Executed `<command>` → Output showed `<evidence>` → **KILLED**
- **Testing H2:** Executed `<command>` → Output showed `<evidence>` → **CONFIRMED**

#### Isolated Cause
- **What this is:** <Plain-English description of the defect, with technical terms explained on first use>
- **Problem:** <The exact condition that triggers it, and the wrong result it produces>
- **Fix:** <Smallest fix that works, with the file and line>
- **If we skip it:** <Concrete cost of leaving it unfixed>
- **Regression test:** <The test that would fail if this bug returned>

#### Not Checked
<Anything that mattered and could not be verified, or "Nothing." >

```

---

## Checklist

* [ ] Exactly 3 distinct, falsifiable hypotheses generated before editing code
* [ ] No application code modified during the diagnostic phase
* [ ] Every hypothesis check performed using zero-mutation commands or temporary logs
* [ ] Root cause backed by direct terminal/log evidence, not inference
* [ ] Verification gate passed: cited lines re-read and trigger condition confirmed before CONFIRMED
* [ ] One hypothesis checked for intended or documented behavior when the report could be one
* [ ] Every caller of the defect site grepped before proposing a fix
* [ ] Regression test named, and "Not Checked" section filled in
* [ ] All temporary diagnostic logs (`// TEMP_TRIAGE`) cleaned up
