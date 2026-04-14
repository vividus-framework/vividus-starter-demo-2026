# VIVIDUS Starter Demo

Test automation project using [VIVIDUS](https://docs.vividus.dev/vividus/latest/) + GitHub Copilot skills to generate and run UI and API tests against the [InvenTree](https://demo.inventree.org) demo app.

## Prerequisites

1. Clone the repo: `git clone --recursive https://github.com/vividus-framework/vividus-starter-demo-2026.git`
2. Open in VS Code with GitHub Copilot extension installed
3. Sign in to Copilot
4. Start MCP servers — open `.vscode/mcp.json` and press **▷ Start** for `vividus-unix` and `playwright`
5. Switch Copilot to **Agent mode** and select a model (e.g. Claude)

## Generating Automated API Tests

Uses the **generate-vividus-api-tests** skill + VIVIDUS MCP server + OpenAPI spec.

1. Open Copilot Chat in Agent mode
2. Prompt: `Create api tests for all /currency/ endpoints` (adjust path and version as needed)
3. Copilot will:
   - Fetch the OpenAPI spec from the InvenTree instance
   - Parse endpoints, schemas, and response codes
   - Query available VIVIDUS steps via the MCP server
   - Generate `.story` files in `src/main/resources/story/rest_api/generated/`
4. Run tests: `./gradlew dS -Pvividus.configuration-set.active=api-demo -Pvividus.variables.username=<USERNAME> -Pvividus.variables.password=<PASSWORD> -Pvividus.variables.apiVersion=<API_VERSION>`
5. View report: open `output/reports/allure/index.html` in a browser

## Generating Automated UI Tests

Uses the **generate-vividus-ui-test** skill + VIVIDUS MCP server + Playwright MCP server.

1. Open Copilot Chat in Agent mode
2. Provide a test case — either as a CSV file or inline in the prompt, e.g.:
   ```
   Test case: Verify creating a new part category
   Steps:
   1. Log in as admin
   2. Navigate to Parts > Categories
   3. Click "New Category", fill in name and description
   Expected: Category is created and visible in the list
   ```
3. Copilot will:
   - Parse the test case steps and expected results
   - Execute steps in a real browser via Playwright MCP to collect element locators
   - Query available VIVIDUS steps via the MCP server
   - Generate a `.story` file and a `summary.md` coverage report in `src/main/resources/story/generated/`
4. Review the generated story and summary, then move the `.story` file to `src/main/resources/story/web_app/`
5. Run tests: `./gradlew dS -Pvividus.configuration-set.active=web-demo -Pvividus.variables.username=<USERNAME> -Pvividus.variables.password=<PASSWORD>`
6. View report: open `output/reports/allure/index.html` in a browser

## Converting Requirements to Test Cases

Requirements conversion into structured test cases is handled by the [generate-test-cases prompt](.github/prompts/generate-test-cases.prompt.md). It scrapes the InvenTree documentation via Playwright MCP, compares pages against `test-cases/root.json` metadata (staleness check), and generates or updates test case files under `test-cases/`.

To run: open Copilot Chat in Agent mode and use the `generate-test-cases` prompt, optionally specifying a target functionality (e.g. `Part Views - Stock`).
