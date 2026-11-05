# Operating the service

Start with read-only checks and use supported admin journeys before reaching for a production console. Technical procedures here are based on code/configuration, not evidence that every workflow has run successfully.

Support hours, availability targets, RTO and RPO are **not agreed**. Dashboard information, assurance reports, policies and incident guidance are maintained in Confluence and are not reproduced or linked here.

## Access and first checks

Obtain authorised access to the intended environment through the team's access process. The previous handover reports PM approval and Azure PIM for production; confirm the current arrangement before use. Application admin permission is separate from Azure/cluster access.

1. Establish impact and environment; check the deployed version at `/healthcheck/sha`.
2. Check `/up`, `/healthcheck` and `/healthcheck/database`. A passing web check does not verify the worker, maps, email or reference-data freshness.
3. Check web and worker rollout/replica status, then admin `/jobs` for failed or delayed work.
4. Inspect relevant application/error logs without copying personal data or credentials into a ticket.
5. Before any mutation, agree the intended change, approval, validation and recovery path.

For an authorised operator with Azure CLI, `kubectl` and `kubelogin`, the Makefile can fetch credentials and show both deployments:

```sh
make production show-service CONFIRM_PRODUCTION=yes
```

This reads deployment status but its prerequisites change the local Azure account/kubeconfig. Expected output includes `find-placement-schools-production` and its `-worker` deployment. Verify cluster and namespace; do not infer them from the Rails environment name alone.

Sources: [Makefile](../Makefile), [health checks](../config/initializers/okcomputer.rb) and [deployment environment matrix](deployment.md#environments).

## Recurring work

The following is [config/recurring.yml](../config/recurring.yml), under the `production` key. No application time zone is configured, so these schedules use the default UTC context. Confirm the effective scheduler clock if platform settings change.

| Schedule | Job/command | Effect |
| --- | --- | --- |
| Daily 00:00 | `DfE::Analytics::EntityTableCheckJob` | Analytics entity checks on the `dfe_analytics` queue |
| Daily 01:00 | `PublishTeacherTraining::Subject::SyncAllJob` | Import subject data |
| Daily 01:00 | `PublishTeacherTraining::Provider::SyncAllJob` | Import provider/address data |
| Daily 02:00 | `BankHolidays::SyncJob` | Import England/Wales bank holidays |
| Daily 03:00 | `GIAS::SyncAllSchoolsJob` | School/address import and attempted removal of absent schools without preferences |
| Daily 09:00 | `UserSignInReminderJob` | School invitation reminders |
| Daily 10:00 | `CompletePlacementPreferenceReminderJob` | School preference-completion reminders |
| Hourly at :12 | `SolidQueue::Job.clear_finished_in_batches` | Clear finished-job records in batches |

Hosted staging (`staging`), development (`az_development`) and review (`review`) do not match that recurring configuration key. Do not expect nightly refreshes or reminders there merely because a worker exists.

[Queue configuration](../config/queue.yml) defines wildcard queue processing, three worker threads and `JOB_CONCURRENCY` defaulting to one process. It only names development/test/production environment sections. Verify startup logs/effective configuration before assuming custom Rails environments inherit that configuration. Hosted workers run `bundle exec bin/jobs`; local Puma can run Solid Queue when `SOLID_QUEUE_IN_PUMA=true`.

On-demand work includes CSV onboarding, Register imports and mail delivery. [ApplicationJob](../app/jobs/application_job.rb) does not enable an application-wide retry policy. Check the failure and side effects before retrying in Mission Control.

## Reminders and mail

- Invitation reminders select school memberships whose user has never signed in, for schools missing next year's preference. Cadence is based on user creation: two weeks ago, then one month earlier, then another month earlier.
- Preference reminders use the user's last sign-in on the corresponding cadence dates, again for next year's missing preferences. A user with several school memberships can receive a reminder for each school.
- Bulk onboarding staggers notification batches of 100 by a minute. Reminder services also stagger batches.
- Membership removal queues an email. Preference creation queues a feedback request; provider selection can queue a survey.
- `deliver_later` is deferred when enqueued on a known bank holiday. See [integration details](integrations.md#notifications-and-bank-holidays).

Reminder replay is not a no-op: there is no universal once-only delivery ledger in these services. Review affected users and queued mail before re-running a reminder job.

Sources: [invitation reminder](../app/services/users/invite/remind.rb), [preference reminder](../app/services/users/placement_preferences/remind.rb), [mailers](../app/mailers/).

## Troubleshooting

| Symptom | Read-only checks | Next boundary |
| --- | --- | --- |
| User cannot sign in | Selected sign-in method, identity callback logs, pre-existing application user and email/UID match | Use approved user onboarding; DfE identity alone does not grant application membership |
| Organisation missing for user | Membership and selected organisation; admin versus regular switching route | Use supported membership/admin flows, not a blind SQL change |
| Schools/providers/subjects stale | Last sync job/logs, source availability, resulting records, environment's recurring configuration | [Import runbook](runbooks/data-imports.md); sync can mutate/delete or partly succeed |
| Map/travel time missing | Browser request to map-key endpoint, effective key configuration, Maps/Routes enablement, quotas and client errors | Empty map-key response is currently HTTP 200; Routes expects complete duration entries |
| Imports appear successful but data missing | Confirmation means enqueueing; check job completion, input identifiers and skipped rows | Compare expected rows with resulting records before replay |
| Mail absent or duplicated | Queue status, template/configuration, bank-holiday deferral, reminder scope and previous replay | Do not blindly retry delivery or restore queued mail |
| Analytics gaps or WAL growth | `dfe_analytics` queue, entity checks, Airbyte/WAL workflow output | Event dispatch and replication are separate; start with repair workflow dry-run |
| Bad release or database loss | Image SHA, migration state, database health and workload status | [Recovery runbook](runbooks/recovery.md) before rollback/restore |

These are code-derived diagnostic paths, not a catalogue of confirmed recurring incidents.

## Existing automated operations

| Workflow | Schedule and scope |
| --- | --- |
| [Database backup](../.github/workflows/backup-db.yml) | Production daily 04:00 UTC; manual environment selection |
| [WAL monitor](../.github/workflows/database-replication-monitor.yml) | Staging/production every six hours |
| [Airbyte repair](../.github/workflows/fix-airbyte-replication.yml) | Production Sunday hourly 00:00-09:00 UTC; scheduled mode can mutate replication slots |
| [Infrastructure validation](../.github/workflows/validate-infrastructure.yml) | Production daily 07:00 UTC |
| [Review reconciliation](../.github/workflows/review-app-reconcile.yml) | Sunday 08:00 UTC; scheduled stale-app deletion |
| [Uncached build](../.github/workflows/build-nocache.yml) | Sunday 12:30 UTC; rebuild only |

Schedules demonstrate configured intent, not successful runs. Use workflow output to verify completion. Recovery and retention evidence are not established by this table.

## Operational changes

Prefer the [import runbook](runbooks/data-imports.md) and [recovery runbook](runbooks/recovery.md). Makefile targets can scale web/worker workloads or enable database logging; these are mutations, may affect cost/data exposure, and can be reverted by subsequent Terraform reconciliation.

Academic years are created on demand by the application; there is no manual year-creation task to schedule. Ownership/cadence for requesting Register data remains a handover question, separate from the existing upload automation.
