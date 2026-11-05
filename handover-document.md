# Find placement schools: developer and operations handover

This guide is the entry point for a team taking responsibility for the service. Start with the purpose and reading path,
then use the focused guides when developing, supporting or recovering it.

Schools publish their willingness to host initial teacher training (ITT) placements for an academic year. Providers find
schools they may want to work with. DfE admin users support organisations, onboard users and import previous-placement
history. The service does not allocate trainees or book placements.

## First steps

1. Follow the [README setup](README.md#setup) and run the [relevant development checks](docs/testing.md).
2. Read [architecture](docs/architecture.md), the [current data model](docs/data-model.md) and
   [application flows](docs/application-flows.md). These include Mermaid diagrams that render in GitHub Markdown.
3. Read the [ADRs](adr/) for decisions, then the [interface reference](docs/api.md) and
   [integration register](docs/integrations.md).
4. Before accessing hosted environments, confirm the approved access process and intended
   [environment](docs/deployment.md#environments). Application admin access and infrastructure access are separate.
5. Before changing live data or traffic, use [operations](docs/operations.md) and the relevant runbook.

## Documentation map

| Need | Reference |
| --- | --- |
| Run the application locally | [README](README.md) |
| Understand system boundaries and code layout | [Architecture](docs/architecture.md) |
| Understand tables, cardinalities, STI and JSONB | [Current data model and ERDs](docs/data-model.md) |
| Understand school/provider/admin journeys | [Application flows](docs/application-flows.md) |
| Change decisions with context | [ADRs](adr/); the initial model is historical, not the current ERD |
| Understand inbound routes and real response behaviour | [HTTP interfaces](docs/api.md) |
| Understand upstream data, Google, Notify and analytics | [Integrations](docs/integrations.md) |
| Choose tests and diagnose local test failures | [Testing](docs/testing.md) |
| Understand environments, CI, releases and Terraform | [Deployment](docs/deployment.md) |
| Diagnose health, queues, reminders or stale data | [Operations](docs/operations.md) |
| Upload previous placements or onboard users | [Data-import runbook](docs/runbooks/data-imports.md) |
| Assess maintenance, failed releases or database recovery | [Recovery runbook](docs/runbooks/recovery.md) |

Dashboard information, assurance reports, policies and incident guidance are maintained in Confluence. Their content
and links are intentionally not included in this repository.

## Ownership and access boundaries

- **Data & Insights** obtains Register previous-placement information; **support** uploads the CSV using the admin journey.
- **Developers** need the local toolchain and synthetic data; initial seeds call public reference-data sources.
- **Application admins** need an existing authorised user record and can access admin journeys and `/jobs`.
- **Infrastructure operators** need separately approved Azure/cluster/workflow access. The earlier handover reported
  PM approval and Azure PIM for production; confirm the current access process before acting.
- The database holds business data, sessions and queue state. Restoring it can also restore pending notifications and
  unfinished wizard sessions.

No agreed support hours, availability targets, RTO or RPO have been supplied. Two web replicas, database high availability
and scheduled backups are implementation settings, not service commitments.

## What this documentation establishes

The technical guides describe repository code and configuration, refreshed from `main` for this handover. They separate
observed behaviour, team-confirmed rationale and unresolved operational questions. They do not claim that a live
integration was exercised, a backup was restored or an incident procedure was rehearsed merely because code exists.

The four retrospective ADRs record the team's confirmed reasons for organisation STI, JSONB placement details,
session-backed wizards and Solid Queue. Their dates are recording dates, not reconstructed historical decision dates.

This handover replaces a single broad draft with linked, focused references. It adds current ERDs, architecture/flow
diagrams, actual interface behaviour, integration contracts, test guidance and operational runbooks; the README and
original ADRs remain the established entry point and historical record.

## Remaining handover questions

| Question | Current position |
| --- | --- |
| What support/recovery commitments apply? | Not agreed; service ownership must decide whether to establish them. |
| When should Register data be requested/imported, and who approves each handoff? | Data & Insights supplies it and support uploads it; cadence and approval details remain unconfirmed. |
| Which restore/replay procedures have been rehearsed successfully? | No evidence is established here. Resolve the [workflow configuration gaps](docs/runbooks/recovery.md#known-configuration-gaps-resolve-before-relying-on-these-workflows) and rehearse before relying on recovery. |
| How is point-in-time database cutover coordinated? | The repository creates a recovered server but does not define a complete service cutover. Platform/change ownership must agree the missing steps. |
| Should AKS/shared-platform adoption have a retrospective ADR? | Implementation is documented; historical rationale has not been supplied. |

These are explicit unknowns, not requests to copy Confluence-held material into the repository.

## Keeping the handover useful

Update the affected guide/diagram with changes to schema, JSONB steps, interfaces, jobs or deployment behaviour.
Use relative Markdown links and fenced `mermaid` blocks. Explain decisions in plain language and record new decisions
with the [existing ADR tool](README.md#docs--adrs). Avoid duplicating generated schema/configuration dumps, secret values
or live user records in prose.
