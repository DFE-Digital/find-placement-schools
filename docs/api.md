# HTTP interfaces

This is primarily a server-rendered application, not a public REST API. Its only application JSON route is used by the browser to obtain the map key. This reference documents existing behaviour; it does not introduce an integration contract for external consumers.

Sources: [routes](../config/routes.rb), [ApplicationController](../app/controllers/application_controller.rb), [OmniAuth configuration](../config/initializers/omniauth.rb) and [health configuration](../config/initializers/okcomputer.rb).

## Interface inventory

| Interface | Consumer and access | Behaviour |
| --- | --- | --- |
| `GET /api/google/map-key` | Signed-in browser using the session cookie | JSON map-key response; details below |
| `GET /up` | Load balancers/health monitoring, no application sign-in | Rails boot health: 200 if booted without exceptions, otherwise 500. Not a complete dependency check. |
| `GET /healthcheck` | Deployment/uptime monitoring, mounted by OkComputer | Aggregate registered checks, including the database; does not test all integrations or the worker |
| `GET /healthcheck/database` | Operators/monitoring | Active Record database check |
| `GET /healthcheck/sha` | Operators/monitoring | Application version from OkComputer |
| `GET /healthcheck/current_env` | Operators/monitoring | Reports `RAILS_ENV`; not proof that the user journey works |
| `GET /sign-in` | Browser, including unauthenticated users | HTML sign-in page |
| `GET /auth/dfe/callback` | DfE Sign-in/OmniAuth when configured | Authentication callback, not a general-purpose data endpoint |
| `GET /auth/failure` | OmniAuth when DfE Sign-in is configured | Clears session and redirects to `/500` with sign-in failure alert |
| `GET /personas`, `POST /auth/developer/callback` | Developer persona authentication only | Available when `SIGN_IN_METHOD` is `persona` (the default) |
| `GET /auth/dfe/sign-out` or `GET /auth/developer/sign-out` | Signed-in browser; route depends on selected method | Clears the application session and redirects to root |
| `/jobs` | Signed-in admin | Mounted Mission Control Jobs UI, not an anonymous API |

OmniAuth supplies the authentication initiation middleware paths. Do not call the callbacks directly to grant access. [Application flows](application-flows.md#sign-in-and-organisation-selection) explains lookup and organisation selection.

## Map key

```http
GET /api/google/map-key
Accept: application/json
```

With an authenticated application session and a configured key:

```json
{ "map_key": "<configured-browser-map-key>" }
```

Current behaviour when `GOOGLE_MAPS_API_KEY` is absent:

```json
{ "map_key": "" }
```

Both use HTTP 200. [GoogleController](../app/controllers/api/google_controller.rb) has a `KeyError` rescue with a 500 error body, but the environment lookup supplies an empty-string default, so a missing variable does **not** enter that error branch. Do not use a successful response as proof that Maps is configured.

Unauthenticated requests are redirected to `/sign-in`, not answered with a JSON 401. The endpoint inherits session authentication and modern-browser checks from `ApplicationController`. An expired session can therefore lead a JSON consumer to an HTML sign-in page. The [map controller](../app/javascript/controllers/map_controller.js) fetches this endpoint from the same origin before loading Google's Maps JavaScript.

The key is deliberately delivered to the browser. Restriction settings and API enablement must be managed in the Google project; an application sign-in requirement is not a substitute for provider-side key restrictions. Do not paste a real key into examples, screenshots or support records.

## HTML routes are not JSON APIs

Organisation search, user management and preference pages use standard Rails HTML routes and multi-page forms. Wizard URLs contain a state key and step, with `PUT` updates. Authentication callbacks and admin CSV imports are not bulk REST interfaces. Do not automate against them without agreeing an explicit contract.

Signed-in non-admin users receive 403 from admin-controller checks. Pundit denial elsewhere is handled with a flash message and redirect, not a uniform JSON error envelope. Normal browser requests use CSRF/session behaviour from Rails and OmniAuth.

## Versioning and limits

There is no API version prefix, OpenAPI document or application-level request limiter in this repository. Domain Terraform config passes `rate_limit_max` of 1000 for production and 300 for development/staging, with `block_ip` enabled. Those are platform module inputs, not a documented requests-per-minute promise: confirm the module's window and scope before making capacity assumptions.

See [domain configuration](../terraform/domains/environment_domains/config/) and [integration contracts](integrations.md). A healthy endpoint does not establish an availability target; service commitments are not agreed.
