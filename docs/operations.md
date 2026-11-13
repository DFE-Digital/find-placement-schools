# Operating the service

This guide helps support staff and developers check whether the service is working and decide what to investigate.
Start by looking, not changing. Use the admin pages where possible; direct access to the live application's console
should be left to someone with the right permission and experience.

These steps come from the code/settings, not a record of successful rehearsals. Support hours, reliability targets,
maximum acceptable recovery time (RTO) and acceptable data loss (RPO) are **not agreed**.
Dashboard information, reports, policies and incident guidance stay in Confluence, without copies or links here.

## Access and first checks

Check you have permission for the right environment. The previous handover described PM approval and Azure PIM
(time-limited elevated access) for production; confirm this is still the process. Being a service admin does not give
you hosting-platform access.

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
| Daily 10:00 | `CompletePlacementPreferenceReminderJob` | School preference-completion reminders |
| Hourly at :12 | `SolidQueue::Job.clear_finished_in_batches` | Remove records of completed tasks in batches |

Staging, hosted development and review apps use different Rails environment names. They do not match this schedule,
so having a worker there does not mean these imports/reminders run automatically.

### For developers: worker settings

[config/queue.yml](../config/queue.yml) asks workers to handle all queues, using three threads (parallel task handlers)
and one process by default (`JOB_CONCURRENCY`). It only names development/test/production sections, so check startup
logs before assuming other environment names inherit them. Hosted workers run `bundle exec bin/jobs`.
Locally, Puma can start Solid Queue when `SOLID_QUEUE_IN_PUMA=true`.

Uploads and emails also create tasks when needed. [ApplicationJob](../app/jobs/application_job.rb) does not define a
shared automatic retry rule. Before rerunning a task in Mission Control, check what it already changed.

## Reminders and mail

- Invitation reminders go to users who have never signed in, where their school has no preference for next year.
  The code selects users created on three particular dates: two weeks ago, one month before that, and another month before that.
- Preference reminders use those same date offsets from the user's last sign-in, for schools missing next year's
  preference. A person working with several schools can get an email for each.
- Bulk onboarding sends invitation batches of 100 a minute apart. Reminder tasks also space their batches apart.
- Removing membership schedules an email. Creating a preference schedules a feedback request; choosing a provider can
  schedule a survey.
- Emails scheduled on a known bank holiday are moved to the next working day. See [email details](integrations.md#notifications-and-bank-holidays).

Running a reminder task again can send emails again. These services do not share a record guaranteeing each message
is sent only once. Check who is affected and what is already waiting before rerunning it.

Sources: [invitation reminder](../app/services/users/invite/remind.rb), [preference reminder](../app/services/users/placement_preferences/remind.rb), [mailers](../app/mailers/).

## Troubleshooting

| Problem | What to check first | What to do next |
| --- | --- | --- |
| User cannot sign in | Sign-in method, sign-in logs and whether their user record matches their email/ID | Use approved onboarding; DfE Sign-in alone does not give access here |
| User cannot see an organisation | Their membership and selected organisation, and which switching page they used | Use admin pages; ask a developer before changing database records directly |
| School/provider/subject information is old | Last import result, source availability and whether this environment has a schedule | Follow the [upload/import guide](runbooks/data-imports.md); a refresh can delete or partly update data |
| Map/travel times are missing | Ask a developer to check the key, Google settings, usage limits and browser errors | A successful key request can contain an empty key; travel requests also need complete results |
| Upload looks successful but records are missing | Was the task only queued? Did it finish, and were identifiers known? | Compare expected and saved records before uploading again |
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
| [Infrastructure validation](../.github/workflows/validate-infrastructure.yml) | Production daily 07:00 UTC |
| [Review reconciliation](../.github/workflows/review-app-reconcile.yml) | Sunday 08:00 UTC; deletes review apps no longer needed |
| [Uncached build](../.github/workflows/build-nocache.yml) | Sunday 12:30 UTC; rebuild only |

The schedules show what is meant to run. Check each workflow's output to see whether it actually succeeded.
This table does not show that recovery has been practised or that retention rules are enforced.

## Operational changes

Use the [upload guide](runbooks/data-imports.md) and [recovery guide](runbooks/recovery.md) for changes.
Developers/operators can also use Makefile shortcuts to change the number of running website/worker copies or turn on
database logs. Those changes can affect cost and what information is logged; a later Terraform run can reset them.

The service creates academic years as needed; there is no annual manual year-creation task.
We still need to confirm when Register data should be requested and who approves the handoff, even though the upload
itself is already supported.
