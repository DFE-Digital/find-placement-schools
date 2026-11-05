# Find placement schools

> A Ruby on Rails application that allows **schools** to publish their placement preferences and **providers** to find
> schools that are open to, or interested in hosting placements to facilitate more placements across the initial teacher
> training (ITT) market.

This service has different interfaces for schools and providers, whilst also allowing users with affiliations to
multiple organisation types to switch between their organisations.

New to the service? Start with the [developer and operations handover](handover-document.md) for a reading
path, architecture diagrams, current ERDs, interface references and runbooks.

## Table of contents

* [Overview](#overview)
* [Architecture](#architecture)
* [Tech stack](#tech-stack)
* [Requirements](#requirements)
* [Setup](#setup)

    * [Prerequisites](#prerequisites)
    * [asdf toolchain](#asdf-toolchain)
    * [Yarn](#yarn)
    * [Environment variables](#environment-variables)
    * [Database](#database)
    * [Node & assets](#node--assets)
* [Running the app](#running-the-app)
* [Authentication](#authentication)
* [Testing](#testing)

    * [Linting & static analysis](#linting--static-analysis)

    * [Intellisense](#intellisense)
* [Docs & ADRs](#docs--adrs)

---

## Overview

This service enables **providers** to find **schools** that may host placements based on their published preferences
and previous-placement history. It does not allocate trainees or book placements.

* **School interface**: create and manage hosting preferences for an academic year.
* **Provider interface**: find schools who the provider may want to work with.
* **Admin interface**: support users and organisations, onboard users and import previous-placement data.

## Architecture

* Server-rendered Ruby on Rails app with an internal map-key JSON endpoint, using the **GOV.UK Design System** via `govuk-components` and
  `govuk_design_system_formbuilder`.
* Two “service contexts”: **schools** and **providers** with distinct navigation and controllers.
* Database-backed **sessions** (`activerecord-session_store`).
* **Solid Queue** for background jobs; **Mission Control Jobs** UI for observability.
* `Rails.cache` for travel times; production does not configure a shared/durable store. The bundled Solid Cache gem is not wired up.
* Geocoding by **geocoder** (e.g. for location-based search).

See [architecture and runtime diagrams](docs/architecture.md) and the [current data model](docs/data-model.md).

## Tech stack

* **Ruby**: *3.4.12* (managed via asdf)
* **Rails**: see [`Gemfile.lock`](Gemfile.lock) for the resolved version
* **DB**: PostgreSQL (tested with **17.2**)
* **Job queue**: `solid_queue`
* **Cache**: `Rails.cache`; see [runtime configuration](docs/architecture.md#main-implementation-choices)
* **Auth**: OmniAuth OpenID Connect (DfE Sign-in)
* **Assets**: `jsbundling-rails` + `cssbundling-rails` (Node + Yarn), `propshaft`
* **HTTP**: `httparty`
* **Pagination**: `pagy`
* **Presentation**: `draper`
* **Logging**: `rails_semantic_logger`
* **Deployment**: Azure Kubernetes Service (AKS), Terraform and GitHub Actions

## Requirements

* Postgres **17.x** (server + headers)
* The Node.js version pinned in [`.tool-versions`](.tool-versions), with Yarn managed by Corepack
* Build tools (for native gems)
* PROJ's `cs2cs` command for GIAS coordinate conversion (`brew install proj` on macOS, `proj-bin` on Debian/Ubuntu)

> macOS users: install `asdf` via Homebrew; Linux users: follow asdf docs.

## Setup

### Prerequisites

This project depends on:

* [Ruby](https://www.ruby-lang.org/)
* [Ruby on Rails](https://rubyonrails.org/)
* [NodeJS](https://nodejs.org/)
* [Yarn](https://yarnpkg.com/)
* [PostgreSQL](https://www.postgresql.org/)

### asdf toolchain

Install the required asdf plugins and the versions pinned for the application in `.tool-versions`:

```sh
brew install asdf # on macOS
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add postgres
asdf install ruby
asdf install nodejs
asdf install postgres
```

When installing the `pg` gem, Bundler executes outside the project directory and can miss the pinned Postgres version.
To ensure `pg` compiles correctly use:

```sh
ASDF_POSTGRES_VERSION=17.2 bundle install
```

Terraform is also pinned in `.tool-versions` for infrastructure work, but is not needed to run the application. To install
it with asdf when working on infrastructure:

```sh
asdf plugin add terraform
asdf install terraform
```

### Yarn

Use [Corepack](https://yarnpkg.com/corepack) to enable the project-pinned Yarn version:

```sh
corepack enable
asdf reshim
yarn --version # 4.9.2
```

The committed `.yarnrc.yml` `yarnPath` points to `.yarn/releases/yarn-4.9.2.cjs`, which is the source of truth for Yarn
in this repository; Yarn is not managed by asdf.

### Quick start

Run the setup script to install gems,
install [Node dependencies](#node--assets), [create the environment variables file](#environment-variables), [create and seed the database](#database),
and [start the development server](#running-the-app):

```sh
  bin/setup
```

This script can be re-run at any time to ensure your environment is up to date.
It uses `db:prepare`; seeds run when Rails prepares a newly created database, not on every normal re-run.
It also clears local logs/tempfiles. To prepare without starting the server, use `bin/setup --skip-server`.
Initial seeding imports GIAS schools and Publish subjects, so allow external network access and provide PROJ.

### Environment variables

We use `dotenv-rails` in development and test. `bin/setup` copies [`.env.example`](.env.example) to
`.env.development.local` if it is absent. Edit that ignored local file; never commit real credentials.

```dotenv
SIGN_IN_METHOD=persona
APP_BASE_URL=http://localhost:3000
SOLID_QUEUE_IN_PUMA=true
```

Retain the public GIAS/Publish base URLs from the example. Replace the Google Maps placeholder before testing maps/routes;
`TBD` is not a working key. Development config uses Notify for email, so use approved development configuration and
recipients before triggering onboarding/reminders. Tests use test mail delivery instead.

For DfE Sign-in, set `SIGN_IN_METHOD=dfe-sign-in`, the issuer/client/secret variables and an approved callback URL.
`APP_BASE_URL` must be an absolute URL including its scheme for callback construction. See the [integration register](docs/integrations.md).

### Database

Create and seed the database:

```sh
bin/setup
# or
bundle exec rails db:create db:migrate db:seed
```

### Node & assets

Install JS and CSS dependencies and build once:

```sh
yarn install
bin/rails assets:precompile # optional for dev; `bin/dev` will build on the fly
```

## Running the app

For local development we recommend `bin/dev` (Procfile-based) which runs Rails, JS and CSS watchers together:

```sh
bin/dev
```

The app should be available at **[http://localhost:3000](http://localhost:3000)**.

## Authentication

DfE Sign-in via OmniAuth OpenID Connect is implemented. `SIGN_IN_METHOD` selects `dfe-sign-in` or
`persona` (the default, used for local development). It does not automatically fall back to personas on failure.
Users also need an application user record and relevant organisation membership.
See [sign-in and organisation selection](docs/application-flows.md#sign-in-and-organisation-selection).

## Testing

We use **RSpec** with **Capybara** and **Selenium WebDriver** for system tests.

```sh
bundle exec rspec
```

Useful notes:

* Screenshots on failure are saved by `capybara-screenshot`.
* Time-sensitive tests use `timecop`.
* External requests are stubbed with `webmock`.
* Controller specs are enabled via `rails-controller-testing`.

See [testing](docs/testing.md) for test database/assets/browser prerequisites, targeted commands and CI behaviour.

### Linting & static analysis

* Ruby style: `rubocop-rails-omakase`
* Security scanner: `brakeman`

`bin/lint` runs RuboCop with `--autocorrect-all` and modifies files. For check-only linting and static analysis, run:

```sh
bin/rubocop
bin/brakeman --no-pager
```

### Intellisense

We bundle `solargraph` + `solargraph-rails`. After installing, index your bundle:

```sh
bin/bundle exec yard gems
```

VS Code setting:

```json
{
  "solargraph.useBundler": true
}
```

## Docs & ADRs

The [handover guide](handover-document.md) indexes the [architecture](docs/architecture.md),
[current ERDs](docs/data-model.md), [application flows](docs/application-flows.md),
[HTTP interfaces](docs/api.md), [integrations](docs/integrations.md), [testing](docs/testing.md),
[deployment](docs/deployment.md), [operations](docs/operations.md) and [runbooks](docs/runbooks/).

We keep Architecture Decision Records in [`/adr`](adr/). Generate a new ADR with:

```sh
bin/bundle exec rladr new "Title of the decision"
```

## Infrastructure validation workflow

The [Validate Infra workflow](.github/workflows/validate-infrastructure.yml) runs Terraform plan validations for the AKS
application plus domains infrastructure/environment each day at **07:00 UTC** against **production** only.
Notifications use the `TEAMS_WEBHOOK_URL_INFRA` secret. See [deployment](docs/deployment.md) for infrastructure boundaries.
