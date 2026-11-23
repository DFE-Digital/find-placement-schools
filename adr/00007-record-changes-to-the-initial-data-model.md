# 7. Record changes to the initial data model

Date: 2026-11-23

## Status

Accepted

Amends [ADR 2: Initial data model](00002-initial-data-model.md).

Written after the changes were built. The date above is when we recorded them, not when each table was added.

## Context

[ADR 2](00002-initial-data-model.md) set out the data model before the service was built. The live schema has since
added tables that ADR 2 does not describe:

- `previous_placements`
- `bank_holidays`
- `sessions`
- the Solid Queue tables (`solid_queue_*`)

Without a record of these changes, the decision history and the running system drift apart. Readers of ADR 2 could
assume it describes the current database.

ADRs are a history of decisions, so we do not rewrite ADR 2. This record explains what was added and why.

## Decision

Keep ADR 2 as the record of the original design. Use this ADR to record the tables added since then:

| Table | Why it exists | Links |
| --- | --- | --- |
| `previous_placements` | Records which schools hosted placements in past academic years, by subject. Admins upload this from a Register trainee teachers CSV supplied by Data and Insights. Providers use it to find schools with hosting experience. | Belongs to a school (`organisations`) and an `academic_years` row. `subject_name` is text, not a link to `placement_subjects`. |
| `bank_holidays` | Stores England and Wales bank holidays from GOV.UK, so emails due on a bank holiday move to the next working day. | None. It does not relate to schools or users. |
| `sessions` | Stores browser sessions in the database through `activerecord-session_store`, including sign-in details and unfinished form answers. | None. Treat contents as sensitive. |
| `solid_queue_*` | Stores background, scheduled and recurring tasks for Solid Queue. See [ADR 6](00006-use-solid-queue-for-background-work.md). | Framework tables only. Not business data. |

Organisations still use single-table inheritance for `School` and `Provider`, as described in
[ADR 3](00003-use-single-table-inheritance-for-organisations.md).

Use the [data model guide](../docs/data-model.md) and [schema](../db/schema.rb) for the current structure, including
columns, rules and diagrams. When a change adds a table or changes a relationship in a way a reader of ADRs 2 and 7 would
not expect, write a new ADR with `bin/bundle exec rladr new "Title"`.

## Consequences

ADR 2 stays accurate as history, and this record explains why the current schema differs from it.

The data model guide, not an ADR, is the reference for the current schema. It must be updated in the same change as
any migration that alters tables or relationships.

Restoring the database also restores sessions and queued tasks, because they live in the same database.
See [recovery](../docs/runbooks/recovery.md).
