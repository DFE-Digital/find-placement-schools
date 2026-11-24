# HTTP interfaces: how the service exchanges information

Most people use this service through web pages and forms. It does not offer a public API: a set of web addresses for
other organisations' software to use. It does have an internal address the browser calls to display maps, and addresses
that help support staff check whether the service is working.

An **endpoint** is one of those addresses. **HTTP** is the way a browser requests a page or data. **JSON** is a structured
text format for data, rather than a page designed for a person to read.

The overview table explains the purpose of each address. The request examples and code notes are for developers;
they describe current behaviour, not a new promise to outside users.

Sources: [routes](../config/routes.rb), [ApplicationController](../app/controllers/application_controller.rb), [OmniAuth configuration](../config/initializers/omniauth.rb) and [health configuration](../config/initializers/okcomputer.rb).

## Interface inventory

| Address | Who uses it | What it does |
| --- | --- | --- |
| `GET /api/google/map-key` | A signed-in user's browser | Supplies the key needed to load Google Maps; details below |
| `GET /up` | Monitoring tools, without application sign-in | Checks that Rails started; it does not test all parts of the service |
| `GET /healthcheck` | Monitoring and release tools | Combines checks, including the database, using the OkComputer library; it does not check every connection or background task |
| `GET /healthcheck/database` | Support/monitoring | Checks the database connection |
| `GET /healthcheck/sha` | Support/monitoring | Reports the running application version |
| `GET /healthcheck/current_env` | Support/monitoring | Reports the Rails environment setting; it does not test a user journey |
| `GET /sign-in` | Browser, including unauthenticated users | HTML sign-in page |
| `GET /auth/dfe/callback` | DfE Sign-in and the OmniAuth sign-in library | Receives the result of signing in; not a general data address |
| `GET /auth/failure` | The sign-in library | Clears sign-in information and sends the user to `/500` with a failure message |
| `GET /personas`, `POST /auth/developer/callback` | Developers using test identities | Available when `SIGN_IN_METHOD` is `persona` (the default) |
| `GET /auth/dfe/sign-out` or `GET /auth/developer/sign-out` | Signed-in users | Clears the session and sends the user to the home page; the address depends on the sign-in method |
| `/jobs` | Signed-in admins | Opens Mission Control Jobs, the page for viewing background tasks |

For developers: `GET` requests information; `POST` submits it. OmniAuth supplies the addresses that start sign-in.
Callback addresses are return points in that process, not a way to grant access directly.
[Application flows](application-flows.md#sign-in-and-organisation-selection) explains what happens after sign-in.

## Map key

The map page asks for a Google Maps key before loading the map. A missing key currently produces an empty answer,
not an error, so a successful web request does not prove that the map will work.

### For developers: requests and responses

```http
GET /api/google/map-key
Accept: application/json
```

For a signed-in user with a configured key, the response is:

```json
{ "map_key": "<configured-browser-map-key>" }
```

If the `GOOGLE_MAPS_API_KEY` setting is missing, the response is:

```json
{ "map_key": "" }
```

Both return HTTP 200, which means the web request succeeded. [GoogleController](../app/controllers/api/google_controller.rb)
includes an error handler for a missing setting (`KeyError`), but its lookup supplies an empty string instead of raising
that error. That handler therefore does not run when the variable is missing.

If the user is not signed in, the service sends them to `/sign-in` rather than returning a JSON 401 ("not signed in").
This can happen if their session expires while the map is loading. The endpoint also uses `ApplicationController`'s
modern-browser checks. The [browser map code](../app/javascript/controllers/map_controller.js) calls it on this service's
own website before loading Google's map library.

The browser needs this key, so it is deliberately sent there. Google project settings must still restrict where the key
can be used and which APIs it can access. Requiring sign-in here does not replace those restrictions.
Keep real keys out of examples, screenshots and support records.

## HTML routes are not JSON APIs

School search, user management and preference forms return pages for people to use. They are not designed as an API for
automated bulk access. Agree how such access should work before building it.

For developers: multi-page form URLs include a state key and step, and use `PUT` to update answers.
Admin checks return 403 ("forbidden") for signed-in non-admins. Other permission failures use Pundit and usually return
the user to a page with a message, rather than a standard JSON error. Rails/OmniAuth manage sessions and protection
against forged form requests, called CSRF protection.

## Versioning and limits

The addresses are not grouped under an API version and there is no OpenAPI specification (a machine-readable API guide).
The application code does not set its own request-rate limit.

Rate limiting happens before requests reach the application, in the Azure Front Door firewall (WAF):

| Environment | Limit |
| --- | --- |
| Production | 1,000 requests per IP address in 5 minutes |
| Staging and development | 300 requests per IP address in 5 minutes |

A visitor over the limit gets HTTP 429 ("too many requests") until the 5-minute window moves on. The limit counts every
request, including pages, assets and the map-key request. Requests from the shared AKS platform's own addresses are
always allowed.

These are the shared platform defaults. They have not been load tested for this service, and the team has not seen any
429 responses.

### For developers: firewall rules and known gaps

The shared [rate-limit module](../terraform/application/vendor/modules/aks/domains/environment_domains/rate_limit.tf)
creates these rules from the [domain settings](../terraform/domains/environment_domains/config/):

- `all`: blocks an IP address after `rate_limit_max` requests in 5 minutes.
- `AKS`: allows the platform's own addresses.
- `blockIP`: created **disabled**, with the placeholder address `10.1.1.1`. Setting `block_ip: true` does not block
  anyone. To block an address, someone must enable the rule and set the real address.

The application has a `/429` route, but `app/views/errors/too_many_requests.html.erb` does not exist. Visiting it
raises a missing-template error. Front Door returns its own 429 response, so users over the limit do not see this page.

See [integrations](integrations.md). An address passing a health check is not a reliability promise; service targets
are not agreed.
