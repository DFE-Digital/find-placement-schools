# 4. Store placement details as JSONB

Date: 2026-11-04

## Status

Accepted

Written after the feature was built. The date above is when we recorded the explanation, not when the choice
was made. The team confirmed the reasons while preparing the handover.

## Context

Early in the service, the questions about placements were complex and still changing. Schools also needed different
questions depending on their answers. A fixed database structure for every answer would have made it harder to
explore and change those questions.

## Decision

Keep the changing answers together in a flexible structure. The multi-page form collects and checks the answers
needed for the school's level of interest and teaching phases.

For developers, this uses PostgreSQL's **JSONB** format in `placement_preferences.placement_details`. JSONB stores
named pieces of information without needing a separate database column for each answer.

The team thinks separate tables may be possible now, but has not reported a performance problem that calls for a
change. Keep the current approach. This record neither starts a redesign nor claims it has been benchmarked.

## Consequences

Questions and answer checks can change without adding a table for every variation.
The trade-off is more responsibility in application code. The database cannot check that an ID inside these answers
still points to a real record (there is no foreign key for it). Search and display code also depend on the saved
question names and where answers sit in the structure.

Changes must account for answers already saved and people partway through a form. If moving to separate tables
would help, explain that benefit and how to move the data safely rather than treating it as automatically necessary.

## Implementation

See [PlacementPreference](../app/models/placement_preference.rb),
[preference wizard](../app/wizards/add_hosting_interest_wizard.rb),
[SchoolsQuery](../app/queries/schools_query.rb) and [JSONB flow/example](../docs/application-flows.md#wizard-state-and-jsonb).
