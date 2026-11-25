# Operating the service

This guide helps support staff and developers check whether the service is working and decide what to investigate.
Start by looking, not changing. Use the admin pages where possible; direct access to the live application's console
should be left to someone with the right permission and experience.

These steps come from the code/settings, not a record of successful rehearsals.
Dashboard information, reports, policies and incident guidance stay in Confluence, without copies or links here.

## Support model

| Question | Team's position |
| --- | --- |
| Who responds? | The development team, during working hours. There is no out-of-hours cover. |
| How severe is it? | Use the Teacher Services incident playbook levels, P1 to P3. |
| Who do we escalate to? | It depends on the fault. For a code fault, revert the pull request. For a hosting fault, go to the infrastructure team. |
| Service levels, RTO and RPO? | None agreed. |
| Incident history? | No incidents to date and no recurring Sentry errors. |

## Access and first checks

Being a service admin does not give you hosting-platform access. For production:

1. Ask the service PM for approval.
2. Activate access through Azure PIM (time-limited elevated access). Approval usually takes 5 to 10 minutes.
3. If the usual approver is away, ask the backup approvers in the team's Teams channels.
4. In an emergency, contact the key people directly.

1. Find out who is affected and which environment has the problem. `/healthcheck/sha` shows the running version.
2. Check `/up`, `/healthcheck` and `/healthcheck/database`. Passing these checks does not prove that emails, maps or
   background tasks work, or that school information is up to date.
3. Ask a developer/operator to check the running website and worker copies. Admins can check `/jobs` for delayed or failed tasks.
4. Read the relevant error reports/logs. Keep personal information and secret values out of tickets.
5. Before changing anything, agree who approves it, what should happen, how to check it and how to recover if it fails.

### For developers/operators: checking the running copies

With approved access and the Azure CLI, `kubectl` and `kubelogin` tools installed, this Makefile shortcut shows the
website and worker status:

```sh
make production show-service CONFIRM_PRODUCTION=yes
```

It reads the status but first changes your local Azure account selection and Kubernetes connection settings.
Expected output includes `find-placement-schools-production` and its `-worker` deployment. Check the cluster/namespace
(the hosting group and area containing the application) against the environment table, rather than guessing from its name.

Sources: [Makefile](../Makefile), [health checks](../config/initializers/okcomputer.rb) and [deployment environment matrix](deployment.md#environments).

### For developers/operators: production console

Use the admin pages first. If a fix needs the Rails console on production, this is the team's procedure:

- Use it at your own discretion, with production access approved as above.
- No second person needs to approve it, and console sessions are not audited.
- Read before you change anything. Record what you ran and the outcome on the support query.

There is no Makefile shortcut for the console. After `make production get-cluster-credentials CONFIRM_PRODUCTION=yes`,
open a shell in the website deployment in the `bat-production` namespace with `kubectl exec`, then run `bin/rails console`.
Hosted copies do not need `config/master.key`: the app does not use encrypted credentials, and `SECRET_KEY_BASE`
comes from the environment.

## Recurring work

These tasks run regularly on production. Times are UTC, so local UK time differs during British Summer Time.
The schedule is in [config/recurring.yml](../config/recurring.yml) under `production`. The application does not set a
different time zone; check the scheduler's clock if hosting settings change.

| Schedule | Job/command | Effect |
| --- | --- | --- |
| Daily 00:00 | `DfE::Analytics::EntityTableCheckJob` | Check application records for reporting through the `dfe_analytics` task queue |
| Daily 01:00 | `PublishTeacherTraining::Subject::SyncAllJob` | Import subject data |
| Daily 01:00 | `PublishTeacherTraining::Provider::SyncAllJob` | Import provider/address data |
| Daily 02:00 | `BankHolidays::SyncJob` | Import England/Wales bank holidays |
| Daily 03:00 | `GIAS::SyncAllSchoolsJob` | Update schools/addresses; try to remove missing schools that have no preferences |
| Daily 09:00 | `UserSignInReminderJob` | School invitation reminders |
| 10:00 on the 1st to 7th of each month | `CompletePlacementPreferenceReminderJob` | School preference-completion reminders. The job only sends on the month's first working day (skipping weekends and bank holidays); other days it does nothing |
| Hourly at :12 | `SolidQueue::Job.clear_finished_in_batches` | Remove records of completed tasks in batches |

Staging, hosted development and review apps use different Rails environment names. They do not match this schedule,
so having a worker there does not mean these imports/reminders run automatically.

### For developers: worker settings

[config/queue.yml](../config/queue.yml) asks workers to handle all queues, using three threads (parallel task handlers)
and one process by default (`JOB_CONCURRENCY`). There is one worker for everything, so a long import can delay emails
and analytics tasks. It only names development/test/production sections, so check startup
logs before assuming other environment names inherit them. Hosted workers run `bundle exec bin/jobs`.
Locally, Puma can start Solid Queue when `SOLID_QUEUE_IN_PUMA=true`.

Uploads and emails also create tasks when needed. [ApplicationJob](../app/jobs/application_job.rb) does not define a
shared automatic retry rule. Before rerunning a task in Mission Control, check what it already changed.

## Reminders and mail

- Invitation reminders go to users who have never signed in, where their school has no preference for next year.
  The code selects users created on three particular dates: two weeks ago, one month before that, and another month before that.
- Preference reminders go out once a month, on the first working day, for schools missing next year's preference.
  A user is reminded only if they last signed in more than two weeks ago. Each user gets at most three reminders per
  school and academic year, at least three weeks apart. A person working with several schools can get an email for each.
- Each preference reminder is recorded in the `placement_preference_reminders` table, so signing in again does not
  reset the count. Reminders sent under the old daily schedule were backfilled into that table when the change deployed.
- Bulk onboarding sends invitation batches of 100 a minute apart. Reminder tasks also space their batches apart.
- Removing membership schedules an email. Creating a preference schedules a feedback request; choosing a provider can
  schedule a survey.
- Emails scheduled on a known bank holiday are moved to the next working day. See [email details](integrations.md#notifications-and-bank-holidays).

Running the invitation reminder again can send emails again, because it keeps no record of what it sent. The preference
reminder is safer: its cap and three-week gap stop a same-day rerun from emailing the same people. Check who is affected
and what is already waiting before rerunning either.

Emails go through the shared Schools Digital GOV.UK Notify account. Notify allows 3,000 emails a minute; the service
sends at most about 100 a minute. Nothing monitors delivery. To check whether an email arrived, look it up in Notify.

Sources: [invitation reminder](../app/services/users/invite/remind.rb), [preference reminder](../app/services/users/placement_preferences/remind.rb), [mailers](../app/mailers/).

## Troubleshooting

| Problem | What to check first | What to do next |
| --- | --- | --- |
| User cannot sign in | Sign-in method, sign-in logs and whether their user record has the same email address as DfE Sign-in | Use approved onboarding; DfE Sign-in alone does not give access here. The service matches users by email, so a changed email address locks them out |
| User cannot see an organisation | Their membership and selected organisation, and which switching page they used | Use admin pages; ask a developer before changing database records directly |
| School/provider/subject information is old | Last import result, source availability and whether this environment has a schedule | Follow the [upload/import guide](runbooks/data-imports.md); a refresh can delete or partly update data |
| Map/travel times are missing | Ask a developer to check the key, Google settings, usage limits and browser errors | A successful key request can contain an empty key; travel requests also need complete results |
| Upload looks successful but records are missing | Were identifiers known? Onboarding can show success with no task if all rows were skipped. If a task exists, did it finish? | Follow the [upload checks](runbooks/data-imports.md#bulk-user-onboarding) before assuming a worker problem or uploading again |
| Email is missing or repeated | Waiting/failed mail tasks, delivery settings, holiday delay and previous reruns | Check before resending or restarting old tasks |
| Reporting is incomplete or database change logs are growing | Analytics queue, record checks and Airbyte monitoring output | The two reporting paths are separate; use the repair tool's no-change dry run first |
| Release failed or data was lost | Running version, database changes/health and website/worker status | Follow the [recovery guide](runbooks/recovery.md) before undoing a release or restoring data |

These suggestions come from how the code works; they are not a list of known recurring incidents.

## Existing automated operations

| Workflow | Schedule and scope |
| --- | --- |
| [Database backup](../.github/workflows/backup-db.yml) | Production daily 04:00 UTC; manual environment selection |
| [WAL monitor](../.github/workflows/database-replication-monitor.yml) | Checks database change-log growth in staging/production every six hours |
| [Airbyte repair](../.github/workflows/fix-airbyte-replication.yml) | Production Sunday hourly 00:00-09:00 UTC; can change the setup used to copy data |
| [Infrastructure validation](../.github/workflows/validate-infrastructure.yml) | Production daily 07:00 UTC; reports drift to the SD Infra alerts Teams channel. The infrastructure team owns fixing drift |
| [Review reconciliation](../.github/workflows/review-app-reconcile.yml) | Sunday 08:00 UTC; deletes review apps no longer needed |
| [Uncached build](../.github/workflows/build-nocache.yml) | Sunday 12:30 UTC; rebuild only |

The schedules show what is meant to run. Check each workflow's output to see whether it actually succeeded.
Backups have never been restored or tested.

No job deletes old data. Expired browser sessions stay in the `sessions` table, and removed users keep their user record.
See [data retention](data-model.md#deletion-is-not-a-retention-policy).

## Security and assurance

| Question | Team's position |
| --- | --- |
| Automated scanning | CI runs Brakeman; the release build scans the container image with Snyk. See [deployment](deployment.md#for-developers-release-automation). |
| Fix times for vulnerabilities | No agreed timescales. |
| Outstanding findings | None known. |
| Pen test, accessibility audit, DSA, DPIA and retention policy | Held by the delivery manager, outside this repository. |
| Secret rotation | Done when needed, with no schedule or written procedure. |

## Operational changes

Use the [upload guide](runbooks/data-imports.md) and [recovery guide](runbooks/recovery.md) for changes.
Developers/operators can also use Makefile shortcuts to change the number of running website/worker copies or turn on
database logs. Those changes can affect cost and what information is logged; a later Terraform run can reset them.

The service creates academic years as needed; there is no annual manual year-creation task.
We still need to confirm when Register data should be requested and who approves the handoff, even though the upload
itself is already supported.
