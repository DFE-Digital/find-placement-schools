# Find placement schools

Find placement schools helps schools say whether they can host trainee teachers, and helps teacher-training providers
find schools to work with.

Schools and providers have different pages. People who work with more than one organisation can switch between them.

**New to the service?** Start with the [handover guide](handover-document.md). It has reading routes for PMs/DMs,
developers and support staff, plus explanations, diagrams and step-by-step guides.
The rest of this README mainly helps developers run their own local copy.

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

Providers can search using schools' published interests and past hosting history.
The service helps them start a conversation; it does not allocate trainees or book placements.

* **Schools**: say whether and how they might host placements for an academic year.
* **Providers**: find schools they may want to work with.
* **Admins**: help users and organisations, add users and upload past-placement information.

## Architecture

The main parts are a website, a database and a worker that handles tasks such as imports and emails.
The website uses the GOV.UK Design System, with separate pages/navigation for schools and providers.

For developers:

* Ruby on Rails prepares pages on the server. An internal JSON address supplies the browser's map key.
* `activerecord-session_store` keeps browser-session information in the database.
* Solid Queue runs background tasks; admins use Mission Control Jobs to see their progress.
* `Rails.cache` temporarily saves travel-time results. Production has no configured shared/durable cache;
  the included Solid Cache library is not connected.
* `geocoder` turns locations into coordinates, for example when searching by location.

See the [architecture diagrams](docs/architecture.md) and [database guide](docs/data-model.md) for explanations.

## Tech stack

These are the main tools/libraries used by the application. You do not need to know them all to read the handover.

* **Ruby**: *3.4.12* (managed via asdf)
* **Rails**: see [`Gemfile.lock`](Gemfile.lock) for the resolved version
* **DB**: PostgreSQL (tested with **17.2**)
* **Job queue**: `solid_queue`
* **Cache**: `Rails.cache`; see [runtime configuration](docs/architecture.md#main-implementation-choices)
* **Sign-in**: OmniAuth OpenID Connect connects to DfE Sign-in
* **Browser scripts/styles**: `jsbundling-rails` + `cssbundling-rails` (Node + Yarn), `propshaft`
* **Requests to other services**: `httparty`
* **Splitting results into pages**: `pagy`
* **Preparing information for display**: `draper`
* **Application logs**: `rails_semantic_logger`
* **Hosting/releases**: Azure Kubernetes Service (AKS), Terraform and GitHub Actions

## Requirements

* Postgres **17.x** (server + headers)
* The Node.js version pinned in [`.tool-versions`](.tool-versions), with Yarn managed by Corepack
* Build tools (for native gems)
* PROJ's `cs2cs` command for GIAS coordinate conversion (`brew install proj` on macOS, `proj-bin` on Debian/Ubuntu)

> macOS users: install `asdf` via Homebrew; Linux users: follow asdf docs.

## Setup

Run these commands on your own development machine, not against a hosted environment.
Local setup downloads public school/subject information; do not copy production data into your local database.

### Prerequisites

This project depends on:

* [Ruby](https://www.ruby-lang.org/)
* [Ruby on Rails](https://rubyonrails.org/)
* [NodeJS](https://nodejs.org/)
* [Yarn](https://yarnpkg.com/)
* [PostgreSQL](https://www.postgresql.org/)

### asdf toolchain

`asdf` manages tool versions so developers use the same ones. Install its plugins and the versions listed in
`.tool-versions`:

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

Run the setup script to install Ruby libraries (gems),
install [browser-build dependencies](#node--assets), [create the settings file](#environment-variables), [create the database and starter data](#database),
and [start the development server](#running-the-app):

```sh
  bin/setup
```

You can run it again to update local setup. It uses `db:prepare`: starter data (seeds) loads for a newly created
database, not every normal rerun. It also clears local logs/temporary files.
Use `bin/setup --skip-server` to prepare without starting the website.
The first load downloads GIAS schools and Publish subjects, so it needs internet access and PROJ.

### Environment variables

Environment variables are named settings supplied when the application starts. In development/test,
`dotenv-rails` reads them from local files. `bin/setup` copies [`.env.example`](.env.example) to
`.env.development.local` if needed. Edit that file for your setup; Git ignores it. Never commit real passwords or keys.

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

Create the database and load starter data:

```sh
bin/setup
# or
bundle exec rails db:create db:migrate db:seed
```

### Node & assets

Assets are the JavaScript (browser behaviour) and CSS (styles) sent to the browser. Install their libraries and build them:

```sh
yarn install
bin/rails assets:precompile # optional for dev; `bin/dev` will build on the fly
```

## Running the app

Use `bin/dev` to run the local website and rebuild browser scripts/styles as files change:

```sh
bin/dev
```

The app should be available at **[http://localhost:3000](http://localhost:3000)**.

## Authentication

`SIGN_IN_METHOD` chooses real DfE Sign-in (`dfe-sign-in`) or test personas (`persona`, the default for local development).
Personas let you try the service as a made-up user. They are not a fallback when real sign-in fails.
Real users also need a user record here and membership of the right organisation; DfE Sign-in alone is not enough.
See [sign-in and organisation selection](docs/application-flows.md#sign-in-and-organisation-selection).

## Testing

RSpec runs our automated tests. Capybara and Selenium WebDriver let browser tests follow a user's steps.

```sh
bundle exec rspec
```

Useful notes:

* Screenshots on failure are saved by `capybara-screenshot`.
* `timecop` lets tests control the date/time.
* `webmock` supplies fake responses instead of calling external services.
* `rails-controller-testing` supports tests of request-handling code.

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

The [handover guide](handover-document.md) links to [how the service fits together](docs/architecture.md),
[what we store](docs/data-model.md), [user journeys](docs/application-flows.md),
[web interfaces](docs/api.md), [other services we rely on](docs/integrations.md), [tests](docs/testing.md),
[releases](docs/deployment.md), [support checks](docs/operations.md) and [step-by-step guides](docs/runbooks/).

Architecture Decision Records (ADRs) explain an important choice, why we made it and its trade-offs.
They live in [`/adr`](adr/). Developers can create one with:

```sh
bin/bundle exec rladr new "Title of the decision"
```

## Infrastructure validation workflow

The [Validate Infra workflow](.github/workflows/validate-infrastructure.yml) checks each day at **07:00 UTC** whether
production hosting differs from the saved Terraform settings for the application and website routing.
It reports through Teams using `TEAMS_WEBHOOK_URL_INFRA`. It does not apply changes.
See [deployment](docs/deployment.md) for the developer details.
