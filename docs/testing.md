# Testing and development checks

Use the [README](../README.md) to set up Ruby, Node/Yarn, Postgres and local configuration first. Tests use a disposable test database: never point `DATABASE_URL` at a hosted or production database.

Sources: [CI](../.github/workflows/ci.yml), [RSpec setup](../spec/rails_helper.rb), [coverage configuration](../spec/spec_helper.rb) and [support helpers](../spec/support/).

## Prepare and run

From the repository root, with local test configuration:

```sh
yarn install --immutable
yarn run build:css
yarn run build
RAILS_ENV=test bin/rails db:test:prepare
bundle exec rspec
```

Dependency installation, asset builds and database preparation write local files/database state. `db:test:prepare` prepares the configured test database; verify the target first. System specs need Chrome/Selenium and built assets, not only Ruby.

Run the smallest relevant selection while developing, for example:

```sh
bundle exec rspec spec/models/academic_year_spec.rb spec/models/placement_preference_spec.rb
bundle exec rspec spec/queries
bundle exec rspec spec/system/placement_preferences
```

The first command covers year and preference model behaviour; choose the corresponding controller, wizard or system tests for behaviour beyond those models. Use the full suite before claiming application-wide validation.

## Where tests live

| Location | Typical responsibility |
| --- | --- |
| [models](../spec/models/) | Validations, associations and domain behaviour |
| [queries](../spec/queries/) | Search/filter/ranking and database interactions |
| [services](../spec/services/) | Import/client orchestration and user services |
| [requests](../spec/requests/) | HTTP responses and access behaviour |
| [policies](../spec/policies/) | Pundit permissions |
| [wizards](../spec/wizards/) | Conditional steps, state and validation |
| [system](../spec/system/) | Browser user journeys |
| [factories](../spec/factories/) and [support](../spec/support/) | Reusable synthetic data, sign-in helpers, stubs and browser configuration |

RSpec uses transactional fixtures and loads support files from `spec/support`. FactoryBot provides synthetic records; fixtures are configured under `spec/fixtures`. WebMock stubs external requests, Timecop controls time-sensitive behaviour and ClimateControl scopes environment changes. Prefer existing helpers over real upstream calls.

Persona system examples tagged `persona_sign_in` temporarily change the sign-in method and reload routes. Ordinary tests should use the existing authentication helpers rather than depend on a hosted identity service.

## Browser and failure diagnostics

[Capybara configuration](../spec/support/capybara.rb) registers a headless Chrome driver with browser version `128` and a 1400x1400 window. CI installs Chrome; driver/browser availability can still affect local runs. Check Selenium output before blaming application code.

Capybara screenshots and test logs are useful diagnostics. CI uploads `tmp/screenshots` when tests fail. Do not add screenshots containing real user data to documentation or pull requests.

SimpleCov starts before Rails and writes HTML/LCOV output under `coverage/`, including branch coverage. There is no configured coverage threshold, and the current CI workflow does not upload a coverage artifact. An overall percentage is not proof that a particular journey is covered.

## Check-only lint and static analysis

```sh
bin/rubocop
bin/brakeman --no-pager
```

`bin/lint` invokes auto-correction and changes files; do not use it as a read-only check. CI runs RuboCop with the GitHub formatter and Brakeman independently of the test job.

## Delivery checks are separate

The deployment workflow requests smoke tests for review apps. Smoke-test inputs are commented out for development, staging and production; those deployments request the configured health check instead. There is no dedicated smoke spec in this repository, so do not describe the shared action's smoke test as a verified copy of the full browser suite.

Read [deployment](deployment.md) before treating CI success as a production release gate: the workflows are separate, and branch-protection settings are not defined here.

## Documentation changes

For Markdown-only changes, check source accuracy, relative links/anchors, Markdown rendering and every changed Mermaid block. Update the [current ERD](data-model.md) when schema/associations change, and the API examples when response shapes change. Use a local renderer or repository preview; do not send private content to public diagram services.

A documentation review does not require executing imports, deployments, backups or recovery commands. State exactly which commands ran and which procedures were only checked against source.
