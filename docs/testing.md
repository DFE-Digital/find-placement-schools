# Testing: checking that changes work

Automated tests check that the service behaves as expected after a change. Some check a small piece of code; others
open a browser and follow a user's steps. Neither kind replaces reviewing whether the change meets the user's need.

This guide is mainly for developers running those checks. PMs/DMs can use it to understand what evidence to ask for:
which behaviour was checked, what passed, and what was not tested.

Follow the [README](../README.md) to set up a local copy first. Tests use a database that can be cleared or rebuilt:
never set `DATABASE_URL` to a hosted or production database when running tests.

Sources: [CI](../.github/workflows/ci.yml), [RSpec setup](../spec/rails_helper.rb), [coverage configuration](../spec/spec_helper.rb) and [support helpers](../spec/support/).

## Prepare and run

### For developers: commands

From the repository root (the main project folder), using local test settings:

```sh
yarn install --immutable
yarn run build:css
yarn run build
RAILS_ENV=test bin/rails db:test:prepare
bundle exec rspec
```

These commands install dependencies, build the browser's styles/scripts and prepare the test database before running
RSpec, our test runner. They write local files and database contents, so check the database target first.
Browser tests need Chrome/Selenium and the built styles/scripts, not just Ruby.

Run the smallest relevant selection while developing, for example:

```sh
bundle exec rspec spec/models/academic_year_spec.rb spec/models/placement_preference_spec.rb
bundle exec rspec spec/queries
bundle exec rspec spec/system/placement_preferences
```

The first example checks year/preference models, not the whole journey. For a form change, also choose the relevant
form/controller or browser tests. Passing a small selection does not mean the whole application has been tested.

## Where tests live

| Location | Typical responsibility |
| --- | --- |
| [models](../spec/models/) | Rules for saving records and their connections |
| [queries](../spec/queries/) | Finding, filtering and ordering results |
| [services](../spec/services/) | Tasks such as imports and user notifications |
| [requests](../spec/requests/) | What web requests return and who can make them |
| [policies](../spec/policies/) | Permission rules |
| [wizards](../spec/wizards/) | Which form questions appear and which answers are allowed |
| [system](../spec/system/) | The steps a user takes in a browser |
| [factories](../spec/factories/) and [support](../spec/support/) | Made-up test records and shared setup, including sign-in and fake external responses |

### For developers: test helpers

RSpec uses database transactions to keep examples separate, and loads shared helpers from `spec/support`.
FactoryBot creates made-up records; fixtures (saved test data) are configured under `spec/fixtures`.
WebMock supplies fake external responses, Timecop lets tests control the date/time, and ClimateControl temporarily
changes environment settings. Reuse these helpers rather than calling real services in tests.

Browser examples marked `persona_sign_in` temporarily select persona sign-in and reload the available web routes.
Use the existing sign-in helpers for ordinary tests rather than depend on a real identity service.

## Browser and failure diagnostics

Capybara controls the browser through Selenium. The [settings](../spec/support/capybara.rb) request Chrome version `128`
with a 1400x1400 window and no visible browser window (headless mode). Automated CI checks install Chrome, but local
browser/driver availability can still cause failures. Read Selenium's error before assuming the application is at fault.

Capybara screenshots and test logs are useful diagnostics. CI uploads `tmp/screenshots` when tests fail. Do not add screenshots containing real user data to documentation or pull requests.

SimpleCov reports which code ran during tests, including which branches of decisions were exercised. It writes a
readable HTML report and machine-readable LCOV data under `coverage/`. There is no required minimum percentage,
and CI does not currently upload that report. A high overall percentage does not prove a specific journey was checked.

## Check-only lint and static analysis

These are checks of the code, not tests of a user journey. RuboCop checks style/rules; Brakeman looks for common
Rails security problems:

```sh
bin/rubocop
bin/brakeman --no-pager
```

`bin/lint` tries to fix issues and changes files, so do not use it for a read-only check.
CI runs RuboCop and Brakeman separately from the tests.

## Delivery checks are separate

A release to a review app asks for smoke tests: basic checks that the new copy works. Development, staging and
production releases ask for a health check instead. There is no dedicated smoke-test spec in this repository, so
we cannot describe the shared release tool's check as the same as our full browser tests.

Read [deployment](deployment.md) before assuming tests must pass before every release. The test and release workflows
are separate, and GitHub's branch-protection rules are not defined here.

## Documentation changes

For documentation-only changes, check the facts, links and how pages/diagrams display. Keep the
[data diagram](data-model.md) and API examples in step with code changes. Use a local Mermaid renderer or repository
preview; do not upload private content to public diagram services.

There is no need to run live imports, releases or restores just to check the wording. Say which checks actually ran
and which procedures were only compared with the source files.
