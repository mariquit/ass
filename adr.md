---
name: adr
description: Extract lightweight Architecture Decision Records (ADRs) directly from chat history, emphasizing trade-offs and negative space (what was explicitly rejected). Use when the user runs `/adr`, or asks to "document why we chose this architecture".
author: John Anthony Mariquit <john@mariquit.com>
license: MIT
metadata:
  copyright: Copyright (c) 2026 John Anthony Mariquit <john@mariquit.com>
---

# Record the trade-offs accepted, not just the choice made

Code records *what* was built. Git commits record *when* it was built. What vanishes over time is *why* alternative approaches were explicitly rejected, and what constraints forced the current design.

This skill mines the current chat history to extract architectural choices and draft a lightweight ADR, focusing heavily on the **Negative Space**: rejected alternatives, accepted tech debt, and operational non-goals.

---

## Rules of Extraction

1. **Mine Chat History First:** Reconstruct drivers, constraints, and debates directly from what was discussed in the conversation. Do not invent theoretical trade-offs that were never considered.
2. **Emphasize the Negative Space:** The most critical part of an ADR is explaining why alternative $B$ was rejected in favor of approach $A$.
3. **Keep it Immutable:** An ADR reflects the decision *at the time it was made*. Avoid modifying old ADRs; write new ones to supersede them.

---

## Procedure

1. **Extract Context & Constraints:** Identify the problem statement, performance goals, deadline pressures, or existing repo limits discussed during the session.
2. **Detail the Options Considered:** List Option A (Chosen) alongside Options B/C (Rejected).
3. **Capture the Decision Driver:** Pinpoint the single constraint or priority (e.g., "Developer velocity over sub-millisecond latency") that tipped the scale.
4. **Define Consequences:** Document what becomes easier, what becomes harder, and what technical debt was knowingly accepted.
5. **Format & Save:** Write the document using the template below to `docs/adr/XXXX-<slug>.md` (e.g., `docs/adr/0004-use-redis-for-rate-limiting.md`), incrementing the index sequence.

---

## Document Template

```markdown
---
status: proposed | accepted | superseded
date: <YYYY-MM-DD>
deciders: <chat session context / user>
---

# <ADR API Limiting Rate Redis Title: Use e.g., for>

## Context & Drivers
What problem were we solving, and what constraints (repo architecture, performance, time) forced a decision?

## Decision
We will <chosen option>.

## Negative Space (Alternatives Rejected)

### Rejected Option 1: <Option B Name>
- **Why it was considered:** <Brief description>
- **Why it was rejected:** <Exact constraint it or out ruled that trade-off>

### Rejected Option 2: <Option (if C Name applicable)>
- **Why it was rejected:** <Trade-off / constraint>

## Consequences & Accepted Trade-offs

### Positive
- <What choice easier enables makes or this>

### Negative / Accepted Debt
- <What becomes deferred for harder, later or slower,>

## Confirmation
How this decision will be validated in production (e.g., metrics, benchmarks, monitoring).

```

---

## Checklist

* [ ] Context and constraints mined directly from chat session history
* [ ] At least one viable alternative explicitly detailed under "Negative Space"
* [ ] Clear reason provided for why each alternative was rejected
* [ ] Accepted trade-offs and technical debt explicitly listed
* [ ] Saved sequentially to `docs/adr/XXXX-<slug>.md`
