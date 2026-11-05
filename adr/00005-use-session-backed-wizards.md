# 5. Use session-backed wizards

Date: 2026-11-04

## Status

Accepted

Retrospective record of the existing implementation. The date above is the recording date, not the original
decision date. The team confirmed the rationale during handover documentation.

## Context

The service needs conditional multi-page forms that follow GOV.UK's one-question-per-page style.
The team had used session-backed wizards successfully on Claim funding for mentor training.

## Decision

Reuse that approach: define steps and validation in wizard/step objects, orchestrate them from controllers and retain
in-progress state in the database-backed Rails session under a generated state key.

The prior service experience and suitability for the question-per-page pattern are the confirmed rationale.
This does not imply the two services have identical implementations.

## Consequences

Controllers can share next/back navigation and state persistence, while each wizard defines its conditional steps.
State is tied to the session rather than being a separate durable draft resource.

Changing step names or shapes can affect unfinished journeys and persisted JSONB details. Sessions can hold uploaded
CSV content and contact information, so they are sensitive data. Some preference details are saved before final
confirmation; an abandoned wizard is not necessarily a transaction with no effects.

## Implementation

See [BaseWizard](../app/wizards/base_wizard.rb), [WizardController](../app/controllers/concerns/wizard_controller.rb),
[session configuration](../config/application.rb) and [application flows](../docs/application-flows.md).
