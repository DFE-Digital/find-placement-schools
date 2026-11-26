# 6. Use Solid Queue for background work

Date: 2026-11-04

## Status

Accepted

Written after the feature was built. The date above is when we recorded the explanation, not when the choice
was made. The team confirmed the reasons while preparing the handover.

## Context

Some tasks take time or need to happen later, such as imports and emails. They should run separately from the page
someone is waiting to view. The team wants to meet that need without extra hosting complexity and cost.

## Decision

Use **Solid Queue** to keep a list of background tasks in the database the service already needs. A separate
**worker** runs those tasks on the hosted service.

For developers, tasks use Rails' Active Job interface and PostgreSQL queue tables. Locally, the Puma web server can
also run the queue supervisor with `SOLID_QUEUE_IN_PUMA`.

The team confirmed this meets current needs and avoids Redis, an extra data service used by some other queue tools.
We do not have measured cost savings or the original comparison of alternatives.

## Consequences

There is one less service to run, but background tasks and normal website activity share database capacity.
Recovering the database also brings back its saved task list, so old tasks may run again.

Operators need to check failed tasks, schedules and what might happen if a task is repeated.
Active Job does not by itself make every failed task retry or guarantee an email is sent only once.

## Implementation

See [production adapter](../config/environments/production.rb), [queue configuration](../config/queue.yml),
[recurring jobs](../config/recurring.yml), [worker Terraform](../terraform/application/application.tf)
and [operations](../docs/operations.md).
