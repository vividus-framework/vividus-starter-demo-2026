# Generate Test Cases

You are a test case generation agent. Follow this protocol exactly.

## Input

- `test-cases/root.json` — the registry of all leaf doc pages with `lastChanged`, `excludes`, and `folder`
- Test case files live in leaf subfolders. They are the single source of truth for scenarios.
- **Optional:** a specific functional node (leaf `folder` value, e.g. `test-cases/tracking/assign-serial-numbers`) may be provided by the user. If provided, process only that node. If not provided, follow the staleness check below to determine which nodes to process.

## Step 1: Determine Scope

**If a specific node was provided by the user:**
- Skip the staleness check entirely
- Process only that node, then jump to Step 2

**Otherwise — check staleness for all nodes:**

For each leaf in `test-cases/root.json`:

1. Open the leaf's `url` via Playwright MCP (`browser_navigate`)
2. Read the page's last updated date from `.git-revision-date-localized-plugin` `title` attribute
3. Compare the live page date against `lastChanged` in `root.json`:
   - **Needs generation** if `lastChanged` is `null`, OR live page date > `lastChanged`, OR the folder has no test case files
   - **Up to date** otherwise

Print a status table showing which leaves need generation and which are fresh. Ask the user which leaves to generate. If the user says "all", process every stale leaf.

## Step 2: Scrape Page Structure (per node)

For each leaf that needs generation:

1. Scrape the page's Table of Contents from `.md-sidebar--secondary .md-sidebar__inner` to get the heading hierarchy (name + anchor)
2. Scrape the page's main content to understand what each section describes
3. Check if the leaf has `excludes` in `root.json` — skip those anchors entirely

## Step 3: Generate Test Case Files

Using the scraped page structure, generate test case files:

1. Delete the existing `test-cases.csv` and any empty subdirectories in the leaf folder
2. Collect all scenarios for the leaf into a single `test-cases.csv` file at `<leaf-folder>/test-cases.csv`
3. Each scenario is one row. The CSV uses `;` as the column separator. Schema:

```
id;name;source;type;tags;steps
```

| Column | Description |
|--------|-------------|
| `id` | Unique test case identifier. Format: `TC-XXXXXX` where `XXXXXX` is a random 6-character uppercase alphanumeric string (e.g. `TC-K7M2P9`). Assign once; never regenerate for an existing scenario. |
| `name` | Descriptive scenario name |
| `source` | Full URL with anchor (e.g. `https://full-url#anchor`) |
| `type` | One of: `positive`, `negative`, `boundary`, `configuration` |
| `tags` | Comma-separated list of tags (e.g. `tag1,tag2`) |
| `steps` | Newline-separated Gherkin steps inside a quoted cell. Each step on its own line. |

### Example row

```csv
id;name;source;type;tags;steps
TC-K7M2P9;"Create part with initial stock";https://docs.inventree.org/en/latest/part/create/#initial-stock;positive;creating-parts,initial-stock;"Given the 'Create Initial Stock' global setting is enabled
When the user clicks 'Submit'
Then the Stock tab shows a stock item with quantity 50"
```

### Scenario rules

- **Steps** must be valid Gherkin: each string starts with `Given`, `When`, or `Then`
- **Given** = preconditions (permissions, settings, existing data, current page)
- **When** = user actions (clicks, fills fields, navigates)
- **Then** = assertions (what should be visible, created, changed)
- Never put an assertion about initial state in `Then` — that belongs in `Given`
- Reference concrete UI elements: button names, field labels, checkbox labels — not vague phrases like "fills out the form"
- **Tags** must be scenario-specific. Do NOT inherit tags from parent nodes
- **Type**: `positive` = happy path, `negative` = error/missing/denied, `boundary` = edge case/limits, `configuration` = setup/settings
- **Then steps must assert specific observable outcomes**, not just "it works." Bad: `"Then the part is created"`. Good: `"Then the part detail page displays 'Test Part 001' as the part name and 'Electronics' as the category"`
- **When steps involving form entry must specify what value is entered** using placeholder values. Bad: `"When the user fills in the form"`. Good: `"When the user enters 'Test Part 001' in the 'Part Name' field"`
- **Each scenario must be independently executable** — all preconditions must appear in Given steps. No hidden dependencies on prior test execution order.

### Coverage dimensions

Apply this checklist to every feature node. For each dimension that applies, generate at least one scenario:

- **CRUD** — can this entity be created, read, updated, deleted? Generate a scenario for each applicable operation
- **Permissions** — is this gated by a permission group? Generate authorized + unauthorized scenarios
- **Visibility toggle** — does a setting or attribute show/hide this feature? Generate enabled + disabled scenarios
- **Validation** — what fields are required? What formats are enforced? Generate missing-field, invalid-format, and duplicate-value scenarios
- **Boundary** — what are the limits? Max length, zero quantity, empty list, special characters in names
- **State transitions** — does the entity have states (active/inactive, locked/unlocked, draft/issued)? Generate scenarios for each transition and for blocked transitions
- **Cross-feature** — does this feature affect or depend on another feature area? Generate a scenario that covers the interaction (e.g., marking a part as Trackable enables serial number assignment in Stock)

### Cross-leaf scenarios

If the scraped page references behavior from another leaf (e.g., the Parts page mentions "Trackable" which links to the Tracking leaf), generate a cross-reference scenario tagged with both feature areas. Place the scenario in the leaf where the user action originates.

### Minimum coverage verification

Before finishing a leaf, verify you have generated scenarios covering:

- Every actionable UI element mentioned on the doc page (buttons, forms, toggles, tabs)
- At least one positive and one negative scenario per feature node
- At least one boundary scenario for every input field or setting
- Permission-gated features tested with both authorized and unauthorized users
- Any constraints, restrictions, or error conditions mentioned in the doc text — scan for words like "must", "cannot", "requires", "only if", "restricted", "prevented" and turn each into a scenario

## Step 4: Update `root.json`

For each leaf that was successfully generated, set `lastChanged` to the live page date scraped in Step 1.

## Slugification

Convert names to folder/file names: lowercase, replace non-alphanumeric runs with `-`, trim leading/trailing `-`.

Example: `"Import a supplier part"` → `import-a-supplier-part`
