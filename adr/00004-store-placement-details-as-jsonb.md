# 4. Store placement details as JSONB

Date: 2026-11-04

## Status

Accepted

Retrospective record of the existing implementation. The date above is the recording date, not the original
decision date. The team confirmed the rationale during handover documentation.

## Context

Placement details were complex and changing during the service's early stages. Defining a fixed set of tables then
would have constrained that exploration. Different preference types also need different validation.

## Decision

Store variable placement details in `placement_preferences.placement_details` as PostgreSQL JSONB, using the wizard
steps to collect and validate the shape appropriate to the selected appetite/phases.

The team considers a table-based structure potentially possible now, but reports no performance concern motivating
a change. Keep the existing representation; this ADR does not approve a normalisation project or claim a benchmark.

## Consequences

The service can adapt question sets and validations without introducing a table for every early variation.
The trade-off is that JSONB references have no database foreign keys and step names become part of a persisted contract.
Search and presentation depend on known JSON paths.

Future changes need to account for existing preferences and in-progress sessions. A decision to normalise should
explain its benefit and migration approach rather than assume that relational storage is automatically required.

## Implementation

See [PlacementPreference](../app/models/placement_preference.rb),
[preference wizard](../app/wizards/add_hosting_interest_wizard.rb),
[SchoolsQuery](../app/queries/schools_query.rb) and [JSONB flow/example](../docs/application-flows.md#wizard-state-and-jsonb).
