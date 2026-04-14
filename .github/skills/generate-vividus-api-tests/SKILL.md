---
name: generate-vividus-api-tests
description: "Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions. Use when: creating API tests, automating REST endpoints, generating test stories from Swagger docs."
argument-hint: "Specify endpoints or coverage scope, and optionally an API version (e.g. '479'). The spec will be fetched automatically via save-openapi.sh."
---

# Generate VIVIDUS API Tests

## Process

1. **Parse** OpenAPI specification
2. **Select** endpoints to automate
3. **Discover** VIVIDUS API capabilities
4. **Generate** VIVIDUS API stories

---

## Step 1: Parse OpenAPI Specification

Run [save-openapi.sh](./save-openapi.sh) to fetch all schema files. Pass the user-specified API version as an argument, or omit it to fetch the latest.

```bash
bash .github/skills/generate-vividus-api-tests/save-openapi.sh [VERSION]
```

The script prints the **absolute path** to the version folder on stdout. The folder contains:

| File | Purpose |
|---|---|
| `api.yaml` | OpenAPI specification — endpoints, schemas, auth |
| `inventree_settings.json` | Global & user settings with names, descriptions, defaults |
| `inventree_filters.yml` | Django template filters (library, name, description) |
| `inventree_tags.yml` | Django template tags (library, name, description) |

Use `read_file` to load `api.yaml` from the version folder. Load the supplementary files (`inventree_settings.json`, `inventree_filters.yml`, `inventree_tags.yml`) when generating tests for endpoints that interact with settings, filters, or tags (see Step 1b).

**ABORT if:** the script fails, exits non-zero, or prints empty/invalid output. Report stderr to the user.

### Extract from specification:
- **API Version**: `info.version` — used as `@apiVersion` meta tag
- **Endpoints**: paths, methods (GET/POST/PUT/DELETE/PATCH)
- **Schemas**: request parameters/bodies, response codes/bodies
- **Authentication**: security schemes
- **Examples**: request/response samples if available

Only OpenAPI 2.0/3.x is supported. **ABORT** if the format is unsupported or the file is empty.

### Step 1b: Load Supplementary Schema Files

After parsing `api.yaml`, determine whether the endpoints under test benefit from supplementary data. Load files from the same version folder as needed:

#### `inventree_settings.json`

Structure: `{ "global": { "<KEY>": { "name", "description", "default", "units" } }, "user": { ... } }`

**Use when** generating tests for:
- Settings endpoints (`/api/settings/global/`, `/api/settings/user/`, etc.) — use real setting keys and their expected defaults for assertions
- Any endpoint that returns or accepts setting keys — validate against known keys
- Tests that require knowledge of server defaults (e.g., `INVENTREE_DEFAULT_CURRENCY` → `"USD"`)

**How to use:**
- Extract real setting keys to use as path/query parameters instead of fabricating them
- Use `default` values for asserting response values on unmodified settings
- Use the `name` and `description` fields to validate detail endpoints return correct metadata

#### `inventree_filters.yml`

Structure: list of `{ name, title, body, library, meta }` — Django template filters grouped by library.

**Use when** generating tests for:
- Label/report template rendering endpoints — reference real filter names (e.g., `floatformat`, `keyvalue` from `inventree_extras`) in template content
- Any endpoint that processes Django template syntax

#### `inventree_tags.yml`

Structure: list of `{ name, title, body, library, meta }` — Django template tags grouped by library.

**Use when** generating tests for:
- Label/report template endpoints — reference real tag names (e.g., `render_date`, `inventree_instance_name` from `inventree_extras`)
- Template validation endpoints — use valid tag syntax in request bodies

**Skip** supplementary files entirely when endpoints have no relation to settings, templates, or rendering.

---

## Step 2: Select Endpoints to Automate

Generate tests based on user input — either **all** endpoints or specific path/method/status combinations.

### Deduplication — Skip Existing Files

Before generating, check whether each story file already exists using the naming convention from Step 4:

```bash
ls src/main/resources/story/rest_api/generated/[method]-[resource]-[status].story
```

- **File exists** → skip and inform: `⚠️ [filename].story already exists — skipping [METHOD] [path] (status [code]).`
- **All exist** → stop: `All requested test files already exist. No new stories were generated.`

---

## Step 3: Discover VIVIDUS API Capabilities

### Logic & Flow Planning

Before choosing steps, plan the test flow:
1. Identify operation sequence (authenticate → create → retrieve → update → delete)
2. Handle dependencies — when testing GET/DELETE for a resource that may not exist, include a **prerequisite POST** in the same scenario with a `!--` comment explaining why
3. Plan positive scenarios (200, 201, 204) and negative scenarios (400, 401, 404, 500)

### Steps Discovery

1. **MUST** call the MCP tool matching pattern `vividus_get_all_features` — **ABORT** if unavailable (instruct user to connect the VIVIDUS MCP server)
2. Read existing patterns in `src/main/resources/story/**/*.story` and `src/main/resources/steps/**/*.steps`

**Rules:**
- Composite steps from `.steps` files **take precedence** over basic VIVIDUS steps
- **ONLY** use steps returned by the MCP tool — NEVER invent or modify steps
- Preserve exact syntax; if a step is missing, mark as `!-- [MISSING STEP]`

---

## Step 4: Story File Guidelines

### File Naming & Location

**Output**: `src/main/resources/story/rest_api/generated/[method]-[resource]-[status].story`

`[resource]` = full path after `/api/`, with path parameters (`{id}`, `{orderId}`, etc.) removed, trailing/leading slashes stripped, and remaining `/` replaced with `-`:

| Path | Resource | Filename example |
|---|---|---|
| `/api/store/inventory` | `store-inventory` | `get-store-inventory-200.story` |
| `/api/store/order/{orderId}` | `store-order` | `post-store-order-201.story` |
| `/api/pet/{petId}/uploadImage` | `pet-uploadImage` | `post-pet-uploadImage-200.story` |
| `/api/parameter/` | `parameter` | `get-parameter-200.story` |
| `/api/parameter/{id}/` | `parameter` | `get-parameter-200.story` |
| `/api/parameter/template/` | `parameter-template` | `get-parameter-template-200.story` |
| `/api/parameter/template/{id}/` | `parameter-template` | `delete-parameter-template-204.story` |

### Meta Tags

```
Meta:
@api
@apiVersion <info.version from spec>
@endpoint <METHOD> <path>
@responseCode <status>
```

### Scenario Structure

1. **Setup** — authenticate, configure headers
2. **Request** — execute HTTP method with parameters/body
3. **Validation** — verify status code, response body, key fields
4. **Cleanup** — delete created resources if needed

### Header Scoping

`When I set request headers:` and `When I add request headers:` apply to the **next HTTP request only**. Repeat the full header table before **each** HTTP request in a scenario.

### Content-Type Header

Include `Content-Type: application/json` for **POST, PUT, PATCH** requests with JSON bodies. Place it in the same header table as `Authorization`, immediately before the request body and HTTP step:

```gherkin
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "#{generate(Name.fullName)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/resource/`
```

Not needed for GET or DELETE.

### Dynamic Data Generation

**NEVER hardcode** field values in request bodies. Use VIVIDUS expressions ([full reference](https://docs.vividus.dev/vividus/latest/commons/expressions.html)):

| Use case | Expression |
|---|---|
| Name, email, address, etc. | `#{generate($DataProvider.$method)}` — delegates to [DataFaker](https://www.datafaker.net/documentation/providers/) |
| Random integer | `#{randomInt($min, $max)}` |
| Pick from set | `#{anyOf($val1, $val2, ...)}` |
| Regex pattern | `#{generate(regexify '$regex')}` |
| Digits (`#`→digit) | `#{generate(numerify '$pattern')}` |
| Letters (`?`→letter) | `#{generate(letterify '$pattern')}` |
| Mixed (`?`/`#`) | `#{generate(bothify '$pattern')}` |
| Computed value | `#{eval($jexlExpression)}` |

Common DataFaker providers: `Name.fullName`, `Name.firstName`, `Company.name`, `Internet.emailAddress`, `Internet.uuid`, `Lorem.sentence`, `Pokemon.name`, `Address.streetAddress`.

When a generated value must be asserted later, save it to a variable first:

```gherkin
Given I initialize scenario variable `templateName` with value `#{generate(regexify '[a-z0-9]{10}')}`
Given request body: {"name": "${templateName}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/resource/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${templateName}`
```

### Response Validation

Always validate: **status code**, **response structure** (per OpenAPI spec), and **key field values**.

#### Collection vs Detail Endpoints

| Response type | Assertion |
|---|---|
| List endpoint (array) | `is greater than \`0\`` or filter by known value: `$.results[?(@.field == 'value')]` |
| Detail endpoint (single object) | `is equal to \`1\`` for scalar fields like `$.pk` |

Never assert an exact count on collection arrays — shared environments may have additional records.

### Parameterization

Use Examples tables for multiple scenarios:

```gherkin
Scenario: Verify GET /api/users with different status codes
When I execute HTTP GET request for resource with relative URL `/api/users/<userId>`
Then response code is equal to `<statusCode>`
Examples:
|userId|statusCode|
|123   |200       |
|999   |404       |
```

### Output Restrictions

**Only** create `.story` files. Do NOT create summaries, READMEs, documentation, or markdown files.
