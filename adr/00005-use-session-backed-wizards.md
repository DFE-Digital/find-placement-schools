# 5. Use session-backed wizards

Date: 2026-11-04

## Status

Accepted

Written after the feature was built. The date above is when we recorded the explanation, not when the choice
was made. The team confirmed the reasons while preparing the handover.

## Context

People answer questions across several pages, with later questions depending on earlier answers.
This follows GOV.UK's one-question-per-page style. The team had already used this approach successfully on
Claim funding for mentor training.

## Decision

Reuse that approach and remember answers while someone moves between pages. In the code, a multi-page form is called
a **wizard**. Its steps define the questions and answer checks; controllers handle the web requests.

Unfinished answers are kept in the user's **session**, the application's saved record of their browser visit.
Rails stores that session in the database and uses a generated key to separate form state.

The team confirmed the previous service's experience and the fit with one-question-per-page as the reasons.
The two services do not necessarily use identical code.

## Consequences

Forms can reuse next/back navigation and answer storage while choosing their own questions.
Unfinished answers belong to the session; they are not a separate draft that a user can always return to later.

Renaming questions or changing answer structures can affect both unfinished forms and saved JSONB details (the
flexible answer format). Sessions can contain uploaded files and contact details, so treat them as sensitive.
Some preference details are saved before final confirmation: leaving a form unfinished does not mean nothing changed.

## Implementation

See [BaseWizard](../app/wizards/base_wizard.rb), [WizardController](../app/controllers/concerns/wizard_controller.rb),
[session configuration](../config/application.rb) and [application flows](../docs/application-flows.md).
