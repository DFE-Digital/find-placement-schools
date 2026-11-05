# 6. Use Solid Queue for background work

Date: 2026-11-04

## Status

Accepted

Retrospective record of the existing implementation. The date above is the recording date, not the original
decision date. The team confirmed the rationale during handover documentation.

## Context

The service needs background imports, notifications and scheduled work. The team does not need a more complex
Redis-based arrangement for these requirements and wants to keep operating costs down.

## Decision

Use Solid Queue through Active Job, with queue state in PostgreSQL and a dedicated worker workload in hosted
deployment. Locally, Puma can run the queue supervisor using `SOLID_QUEUE_IN_PUMA`.

The team confirmed that this meets current needs and avoids introducing Redis. No quantified cost comparison or
original alternatives assessment has been supplied.

## Consequences

Background execution can use the database already needed by the service rather than an additional Redis dependency.
Queue work and business activity share database resources, and database recovery restores queued work as well.

Operators must check failed jobs, recurring configuration and replay side effects. Using Active Job does not itself
provide an application-wide retry policy or exactly-once notification delivery.

## Implementation

See [production adapter](../config/environments/production.rb), [queue configuration](../config/queue.yml),
[recurring jobs](../config/recurring.yml), [worker Terraform](../terraform/application/application.tf)
and [operations](../docs/operations.md).
