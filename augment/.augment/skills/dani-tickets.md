---
type: agent_requested
name: Dani Tickets
description: Write full tickets with acceptance criteria from an approved slice plan
when_to_use: when Dani has produced an approved slice plan and full tickets need to be written
model: sonnet4.6
version: 1.0.0
prerequisites:
  - dani
next_skills:
  - grey
---

# Dani Tickets

**Preferred model:** Claude Sonnet (or Haiku for simple tickets)
**Deterministic first:** Read the slice plan and any PRD before writing tickets.
**External side effects:** None

**Reads:**
- `.agent/notes/slice-plan.md` (approved slice titles)
- `.agent/notes/prd-*.md` (for context)

**Writes:**
- `.agent/tickets.md`

## Rule

This is mechanical transformation, not design. The scope challenge and slice design already happened in Dani. Your job is to expand approved titles into full tickets with clear acceptance criteria.

Do not:
- Re-litigate scope
- Add new tickets
- Reorder tickets
- Question the plan

If something is unclear, ask — don't invent.

## Process

1. Read the slice plan (`.agent/notes/slice-plan.md`)
2. Read any PRD for context
3. For each slice title, write a full ticket with AC
4. Present tickets for approval

## Ticket format

```
## [ ] t-N: <title from slice plan>

<one paragraph context — what and why>

AC:
- <concrete, testable criterion>
- <another criterion>
- ...
```

## Acceptance criteria rules

- Each AC item is testable (pass/fail, not subjective)
- AC items are ordered by implementation sequence when possible
- No implementation details — describe the behavior, not the code
- If the PRD has specific requirements, include them

## Mikado prereq insertion

When Grey escalates a blocked ticket:

1. Read the blocked ticket and Grey's note
2. Identify the minimum work that unblocks it
3. Insert new tickets immediately above the blocked ticket
4. Number them clearly (e.g. if `t-4` is blocked, add `t-4a`, `t-4b` before it)
5. Remove the `blocked:` note from the original ticket
6. Present the updated tickets for approval

## Next skill

- `grey`
