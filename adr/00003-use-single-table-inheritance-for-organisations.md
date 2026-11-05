# 3. Use single-table inheritance for organisations

Date: 2026-11-04

## Status

Accepted

Retrospective record of the existing implementation. The date above is the recording date, not the original
decision date. The team confirmed the rationale during handover documentation.

## Context

Schools and providers share most organisation fields and need to work with the same commands. Only some attributes
and behaviours differ. Separate representations would make those shared operations harder to keep consistent.

## Decision

Use one `organisations` table, with `School` and `Provider` inheriting from `Organisation` through Rails single-table
inheritance (STI). Keep shared relationships and behaviour in the base model and type-specific validation in the subclasses.

The shared-command requirement and mostly shared fields are the team's confirmed reasons for this choice. No original
alternatives assessment has been supplied.

## Consequences

Schools and providers can participate in common membership and organisation-selection flows. The table also contains
fields that only apply to one type, so callers must not assume every organisation has a school URN or provider code.

Type-specific partial unique indexes protect school URNs and provider codes. Changing STI names or splitting the table
requires a migration/compatibility plan for references and existing data.

## Implementation

See [Organisation](../app/models/organisation.rb), [School](../app/models/school.rb),
[Provider](../app/models/provider.rb) and the [current ERD](../docs/data-model.md).
