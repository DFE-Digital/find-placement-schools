# 3. Use single-table inheritance for organisations

Date: 2026-11-04

## Status

Accepted

Written after the feature was built. The date above is when we recorded the explanation, not when the choice
was made. The team confirmed the reasons while preparing the handover.

## Context

Schools and training providers both have names, contact information and users who belong to them. Much of the code
needs to treat them in the same way, although some details differ. Keeping two completely separate ways of storing
them would make those shared tasks harder to keep consistent.

## Decision

Store schools and providers together, so shared tasks can use the same code. Keep rules that only apply to a school
or provider with that type.

For developers, Rails calls this **single-table inheritance (STI)**. `School` and `Provider` build on `Organisation`
and use the same `organisations` table.

The team confirmed shared commands and mostly shared fields as the reasons. We do not have the original comparison
of alternatives.

## Consequences

Membership and organisation-choice pages can work with either type. Some columns only apply to one type:
do not expect every organisation to have a school URN (school number) or a provider code.

The database prevents duplicate school URNs and duplicate provider codes for the relevant types, using partial unique
indexes. Renaming the types or separating the table later would need a plan to move existing data and keep links working.

## Implementation

See [Organisation](../app/models/organisation.rb), [School](../app/models/school.rb),
[Provider](../app/models/provider.rb) and the [current ERD](../docs/data-model.md).
