---
name: generate-vividus-api-tests
description: 'Generate VIVIDUS API test automation stories from OpenAPI/Swagger specifications. Creates executable .story files for API endpoints following VIVIDUS syntax and project conventions. Use when: creating API tests, automating REST endpoints, generating test stories from Swagger docs.'
argument-hint: 'Specify endpoints or coverage scope. The spec will be fetched automatically via save-openapi.sh.'
allowed-tools: shell
---

# Process Overview

1. **Parse** OpenAPI specification
2. **Select** endpoints to automate
3. **Discover** VIVIDUS API capabilities
4. **Design** VIVIDUS API test coverage and structure
5. **Generate** VIVIDUS API stories

---

## Step 1: Parse OpenAPI Specification

### Obtain OpenAPI Specification

**MUST** run the script `.github/skills/generate-vividus-api-tests/save-openapi.sh` to fetch the OpenAPI specification before proceeding. Execute it via shell:

```bash
bash .github/skills/generate-vividus-api-tests/save-openapi.sh
```

The script saves the specification to a file inside the repository and prints the **absolute path** to that file on stdout (e.g. `/path/to/repo/.github/skills/generate-vividus-api-tests/openapi.yaml`). Capture the path from stdout and use `read_file` (or an equivalent tool) to load the specification from that path for parsing below.

**ABORT** if the script fails, exits with a non-zero code, or produces empty/non-path output. Report the error (from stderr) to the user and stop.

### Parse specification and extract:
- **Base URL**: API server address
- **Endpoints**: All available paths
- **Methods**: GET, POST, PUT, DELETE, PATCH for each path
- **Request schemas**: Parameters, headers, body structure
- **Response schemas**: Status codes, response bodies, headers
- **Authentication**: Security schemes (API key, OAuth, Bearer token)
- **Examples**: Request/response examples if available

**ABORT** further execution if:
- The script `.github/skills/generate-vividus-api-tests/save-openapi.sh` fails or is not found
- The script produces empty output or does not print a valid file path
- The file at the printed path is empty or missing
- Specification format is not supported (only OpenAPI 2.0/3.x supported)

When aborting, report the script output or error and ask the user to fix the script before retrying.

---

## Step 2: Select Endpoints to Automate

Determine which endpoints to generate tests for based on user input:

### Option A: Full Specification
Generate tests for **all** endpoints when user requests complete coverage.

### Option B: Specific Combinations
Generate tests only for user-specified combinations:
- **Path**: `/api/users`, `/api/products`, etc.
- **Method**: GET, POST, PUT, DELETE, PATCH
- **Response Code**: 200, 201, 400, 401, 404, 500, etc.

**Examples**:
- "Create tests for GET /api/users with 200 and 404 responses"
- "Create tests for all POST methods returning 201"
- "Create tests for /api/orders endpoint, all methods"

---

## Step 3: Discover VIVIDUS API Capabilities

### Logic & Flow Planning

**Before choosing any steps**, plan the logical flow of the API test to ensure correctness.
1. Identify API operations sequence (e.g., "Authenticate", "Create resource", "Retrieve resource", "Update resource", "Delete resource")
2. Ensure request dependencies are handled (e.g., "POST user must succeed before GET user by ID", "Authentication token required before protected endpoints")
   - When testing GET or DELETE for a resource that may not exist, include a **prerequisite POST/creation step** within the same scenario to guarantee the resource exists. Add a `!--` comment explaining the dependency (e.g., `!-- Create order first to ensure it exists for retrieval`).
3. Plan positive and negative scenarios:
   - **Positive**: Valid request → Expected success response (200, 201, 204)
   - **Negative**: Invalid request → Expected error response (400, 401, 403, 404, 409, 500)
4. Verify the test validates failure states correctly (e.g., 404 when resource not found, 401 when unauthorized)

### VIVIDUS API Steps Discovery

1. **MUST** fetch available VIVIDUS API steps by calling the MCP tool matching pattern `vividus_get_all_features`
   - **ABORT** if the VIVIDUS MCP tool is not available or not connected. Instruct the user to connect the VIVIDUS MCP server before proceeding. Without this tool, valid steps cannot be discovered and stories will contain incorrect syntax.
2. Read existing API test patterns:
   - `src/main/resources/story/**/*.story` — existing API stories
   - `src/main/resources/steps/**/*.steps` — reusable composite steps for API testing
3. Learn from examples: HTTP methods, request/response validation, authentication patterns

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

**Strict rules:**
1. **ONLY use steps returned by the MCP tool matching pattern `vividus_get_all_features`** — NEVER invent, modify, or assume steps
2. **Preserve exact syntax** — do not alter step parameters or structure
3. **If a required step is NOT available** — mark as `!-- [MISSING STEP]` in story
4. **Do not add indentation or formatting** — maintain VIVIDUS step syntax exactly as defined

---

## Step 4: VIVIDUS API Story Guidelines

### General Rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **HTTP Methods:** Support GET, POST, PUT, DELETE, PATCH
3. **Data Tables:** Use Examples blocks for parameterized API tests
4. **Composite Steps:** Reuse existing composite steps for common API patterns
5. **Variables:** Store and reuse response data using VIVIDUS variables
6. **Request Headers Scope:** `When I set request headers:` and `When I add request headers:` apply to the **first subsequent HTTP request only**. Repeat the full header table immediately before **each** HTTP request step in the same scenario.

### API Test Structure

Each API test scenario should follow this pattern:

1. **Setup**: Configure base URL, headers, authentication
2. **Request**: Execute HTTP method with parameters/body
3. **Validation**: Verify status code, response body, headers
4. **Cleanup**: (if needed) Delete created resources

### Authentication Handling

Support common authentication methods from OpenAPI specification:
- **API Key**: Header or query parameter
- **Bearer Token**: Authorization header
- **Basic Auth**: Username/password
- **OAuth2**: Token-based authentication

**Example**:

```gherkin
Given I initialize story variable `apiKey` with value `#{envVars.API_KEY}`
When I set request headers:
|name          |value           |
|Authorization |Bearer ${apiKey}|
```

### Request Body Handling

For POST/PUT/PATCH requests with JSON bodies:

✅ **Good** - inline JSON for simple bodies:

```gherkin
Given request body: {"name": "Test User", "email": "test@example.com"}
```

### Content-Type Header

**ALWAYS include `Content-Type: application/json` header for every POST, PUT, and PATCH request** that sends a JSON body. Without it the server may reject the request or misinterpret the body.

Place the `Content-Type` row in the same `When I add request headers:` table as the `Authorization` header immediately before the request body and the HTTP request step:

```gherkin
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "#{generate(Name.fullName)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/resource/`
```

**Rules:**
- `Content-Type` is **required** for: POST, PUT, PATCH
- `Content-Type` is **not needed** for: GET, DELETE (no request body)

### Dynamic Data Generation

**NEVER use hardcoded static values** for fields in request bodies when creating or modifying entities (names, emails, titles, descriptions, identifiers, etc.). Hardcoded values cause test collisions in shared environments and make tests non-idempotent.

**ALWAYS pick the most appropriate VIVIDUS expression** for each field type. Full expression reference: https://docs.vividus.dev/vividus/latest/commons/expressions.html

#### Choosing the right expression

| Use case | Expression | Example output |
|---|---|---|
| Realistic names, emails, addresses, companies, etc. | `#{generate($DataProvider.$method)}` | `John Smith`, `john@example.com` |
| Random integer in a range | `#{randomInt($min, $max)}` | `42` |
| Pick one from a fixed set of values | `#{anyOf($val1, $val2, $val3)}` | `active` |
| String matching a regex pattern | `#{generate(regexify '$regex')}` | `409Y` |
| Digits-only pattern (`#` → digit) | `#{generate(numerify '$pattern')}` | `test5862test` |
| Letters-only pattern (`?` → letter) | `#{generate(letterify '$pattern')}` | `testNJMYtest` |
| Mixed letters and digits (`?`/`#`) | `#{generate(bothify '$pattern')}` | `2o7v0g9` |
| Computed / derived value | `#{eval($jexlExpression)}` | `28` |

**`#{generate(...)}` data providers** — delegates to [DataFaker](https://www.datafaker.net/documentation/providers/). Common providers:

| Field type | Expression |
|---|---|
| Full name | `#{generate(Name.fullName)}` |
| First name | `#{generate(Name.firstName)}` |
| Company name | `#{generate(Company.name)}` |
| Email address | `#{generate(Internet.emailAddress)}` |
| Description / sentence | `#{generate(Lorem.sentence)}` |
| Single word | `#{generate(Lorem.word)}` |
| UUID | `#{generate(Internet.uuid)}` |
| Street address | `#{generate(Address.streetAddress)}` |
| Pattern-based string | `#{generate(regexify '\d{3}\w{1}')}` |

✅ **Good** — each expression picks the most semantically appropriate generator:

```gherkin
Given request body: {"name": "#{generate(Name.fullName)}", "email": "#{generate(Internet.emailAddress)}", "quantity": "#{randomInt(1, 100)}", "status": "#{anyOf(active, pending, closed)}"}
```

❌ **Bad** — hardcoded static values that break on re-runs or in shared environments:

```gherkin
Given request body: {"name": "Test User", "email": "test@example.com", "quantity": "5", "status": "active"}
```

When the generated value must be referenced later (e.g. to assert it in a GET response), save it to a variable first:

```gherkin
Given I initialize scenario variable `templateName` with value `#{generate(Lorem.word)}`
Given request body: {"name": "${templateName}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/resource/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${templateName}`
```

### Response Validation

Always validate at minimum:
1. **Status code**: Verify expected HTTP status
2. **Response schema**: Check structure matches OpenAPI spec
3. **Critical fields**: Validate key response values

**Example**:

```gherkin
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.id` is equal to 1
Then JSON element value from `${response}` by JSON path `$.name` is equal to `Test User`
```

### Array / Collection Validation

When validating arrays or lists in responses (e.g. `$.results`, `$.items`, `$.data`), **never assert an exact count of elements** unless the test controls the full data set. A shared or pre-populated environment may already contain more items than expected.

**Rules:**

1. **Do NOT use `is equal to 1` or any fixed count** for arrays that represent collection endpoints (e.g. a list of resources). This will fail when other records exist.
2. **Instead, assert `is greater than 0`** to confirm the array is non-empty:
   ```gherkin
   Then number of JSON elements from `${response}` by JSON path `$.results` is greater than 0
   ```
3. **When a resource was created as a prerequisite**, verify that the specific item appears in the response by searching for it using its known field value rather than relying on count:
   ```gherkin
   Then number of JSON elements from `${response}` by JSON path `$.results[?(@.name == 'Test User')]` is equal to 1
   ```
4. **For single-object responses** (detail endpoints such as `GET /api/resource/{id}/`), asserting count `is equal to 1` for a single scalar field (e.g. `$.pk`) is correct and expected.

**Summary table:**

| Response type | Correct assertion |
|---|---|
| List/collection endpoint (array of items) | `is greater than \`0\`` or filter by known value |
| Detail endpoint (single object field) | `is equal to \`1\`` |
| Prerequisite-created item in a list | Filter JSON path: `$.results[?(@.field == 'value')]` count `is equal to 1` |

### Parameterization with Examples

Use Examples tables for testing multiple scenarios:

```gherkin
Scenario: Verify GET /api/users with different status codes
When I execute HTTP GET request for resource with relative URL `/api/users/<userId>`
Then response code is equal to `<statusCode>`
Examples:
|userId|statusCode|
|123   |200       |
|999   |404       |
|abc   |400       |
```

---

## Step 5: Generate VIVIDUS API Story

### Output Folder Structure

Create folder for generated API tests:

```text
src/main/resources/story/generated/api/[ServiceName]/
└── [endpoint-name].story     # VIVIDUS API story file
```

**ServiceName**: Derive from `info.title` in the OpenAPI spec. Use PascalCase with spaces removed. Example: `"Swagger Petstore"` → `SwaggerPetstore`, `"User Management API"` → `UserManagementAPI`.

**DO NOT create:**
- Summary reports
- README files
- Additional documentation
- Any markdown files

### Story File Structure

**Location**: `src/main/resources/story/generated/api/[ServiceName]/[endpoint-name].story`

**Meta Tag Guidelines for API Tests**:

| Tag | Format | Description |
|-----|--------|-------------|
| `@api` | Fixed | Marks as API test |
| `@endpoint` | `GET /api/users` | HTTP method + path |
| `@responseCode` | `200`, `404`, `500` | Expected status code |

**Naming Convention**:
- File: `[method]-[resource]-[status].story`
- `[resource]` is the **last meaningful path segment** (exclude path parameters):
  - `/store/inventory` → `inventory`
  - `/store/order` → `order`
  - `/store/order/{orderId}` → `order` (ignore `{orderId}`)
  - `/pet/{petId}/uploadImage` → `uploadImage`
- Examples: `get-inventory-200.story`, `post-order-200.story`, `get-order-404.story`
