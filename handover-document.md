# Find placement schools: developer and operations handover

Start here if you are joining the team or taking responsibility for the service. You do not need to know how the code
works to read this guide. It explains what the service does, where to find help and what the team still needs to decide.

Schools use the service to say whether they would like to host trainee teachers. Teacher training providers use that
information to find schools to work with. DfE support staff help users get access and upload information about past
placements. The service does not match individual trainees to schools or book their placements.

## First steps

Choose the route that fits your role:

- **Product managers, delivery managers and anyone new to the service:** read
  [how the service fits together](docs/architecture.md), [what users can do](docs/application-flows.md) and
  [the other services we rely on](docs/integrations.md). Then review the open questions below.
- **Developers:** start with those guides, then follow the [README setup](README.md#setup) to run a copy on your
  computer. Read the [data guide](docs/data-model.md), [test guide](docs/testing.md) and
  [decision records](adr/) as you start working on the code.
- **Support and operations staff:** read [day-to-day checks](docs/operations.md) and the step-by-step guides
  for [uploads](docs/runbooks/data-imports.md) and [recovery](docs/runbooks/recovery.md).

Before using a hosted copy of the service, confirm which [environment](docs/deployment.md#environments) you need and
how to get permission. Being an admin in the service does not also give you access to its hosting platform.

## Documentation map

| Need | Reference |
| --- | --- |
| Run the application locally | [README](README.md) |
| See how the service fits together | [Architecture](docs/architecture.md) |
| Understand what information we keep and how it is connected | [Data model and diagrams](docs/data-model.md) |
| Follow the steps users take | [Application flows](docs/application-flows.md) |
| Understand why we made technical choices | [Architecture Decision Records (ADRs)](adr/) |
| Find the web addresses the application uses to exchange information | [HTTP interfaces](docs/api.md) |
| Understand the other services we rely on | [Integrations](docs/integrations.md) |
| Choose tests and diagnose local test failures | [Testing](docs/testing.md) |
| Understand how we release changes | [Deployment](docs/deployment.md) |
| Check whether the service and its scheduled tasks are working | [Operations](docs/operations.md) |
| Upload previous placements or onboard users | [Data-import runbook](docs/runbooks/data-imports.md) |
| Assess maintenance, failed releases or database recovery | [Recovery runbook](docs/runbooks/recovery.md) |

Dashboard information, assurance reports, policies and incident guidance are maintained in Confluence. Their content
and links are intentionally not included in this repository.

## Who does what

- **Data & Insights** gets information about past placements from Register trainee teachers; **support** uploads it
  as a CSV file (a spreadsheet saved as plain text).
- **Developers** need the software listed in the README and made-up test data. First-time setup also downloads
  public school and subject information.
- **Application admins** need an existing authorised user record and can access admin journeys and `/jobs`.
- **People managing hosting** need separate permission to use Azure and the release tools. The earlier handover
  described approval through the PM and time-limited Azure access; confirm that this is still the process.
- **Anyone recovering the database** needs to account for unfinished forms and waiting tasks as well as school/user
  information. Restoring an old copy can bring back emails that were waiting to be sent.

Support hours and reliability targets are **not agreed**. Nor are the maximum acceptable recovery time or amount of
data loss after an outage. Running extra copies of the application and taking backups helps, but does not settle those
decisions.

## What these guides can tell you

The guides explain what the code and settings currently say. Where the team has explained a decision, we say so.
Where something is still unknown, we leave it as an open question. Having a backup script, for example, is not the same
as showing that we have successfully recovered the service from a backup.

Four decision records explain why schools/providers share a storage structure, why placement answers use a flexible
format, why forms run over several pages and why we use Solid Queue for background tasks. We wrote these records after
the choices were made, so their dates show when we recorded the explanation, not when the team originally decided.

Each guide starts with the explanation, followed by details for people working on that part of the service. The README
still explains setup, and the original decision records remain as a history of the early design.

## A few useful terms

| Term | What it means here |
| --- | --- |
| Environment | A separate copy of the service. Production is the one real users use; other copies are for checking changes. |
| Database | Where the service keeps information, such as users, schools and placement preferences. |
| Session | The information the service remembers during a visit, including sign-in and unfinished form answers. |
| Background job / queue | A task waiting to run without making a user keep a page open, such as sending an email. |
| API / endpoint | A way for software to request information from another part of the service or another service, using a particular web address. |
| Data model / ERD | An explanation or diagram of the information we store and how the records connect. ERD means entity relationship diagram. |
| ADR | Architecture Decision Record: a short explanation of a technical choice and why it was made. |
| Deployment | Releasing a version of the application to a hosted environment. |
| Runbook | A step-by-step guide for a support or maintenance task. |

## Remaining handover questions

| Question | Current position |
| --- | --- |
| What support and recovery promises should the service make? | Not agreed; the service owner needs to decide these. |
| When should we ask for Register data, and who approves the upload? | Data & Insights supplies it and support uploads it. The timing and approval steps still need confirming. |
| Have we practised restoring data and safely restarting tasks? | These guides do not establish that. Fix or resolve the [known settings gaps](docs/runbooks/recovery.md#known-configuration-gaps-resolve-before-relying-on-these-workflows) before relying on the recovery tools. |
| How would we switch the service to a recovered database? | A tool can create a recovered copy, but the full switchover steps still need agreeing with the hosting team. |
| Why was the shared Azure hosting platform chosen? | We have documented how it is used, but do not yet have the original reason for that choice. |

These questions are separate from the material kept in Confluence; we are not asking for that material to be copied here.

## Keeping the handover useful

When changing how the service works, update the matching explanation and diagram in the same change.
Explain the purpose first, define unfamiliar terms and put code-level details in a clearly labelled section.
Record new decisions with the [existing ADR tool](README.md#docs--adrs).

For developers: keep links relative to the document and diagrams in fenced `mermaid` blocks so GitHub can display them.
Link to source files instead of copying large amounts of code or settings. Never include secret values or real user data.
