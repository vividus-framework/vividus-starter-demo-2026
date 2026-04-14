---
name: generate-vividus-ui-test
description: 'Generate VIVIDUS test automation stories from test cases for web applications. Creates executable .story files following VIVIDUS syntax and project conventions. Use when: converting manual test cases to automated VIVIDUS stories, creating UI test automation from test specifications.'
argument-hint: 'Enter your test case...'
---

# Process Overview

1. **Retrieve** test cases to automate
2. **Execute** test cases with Playwright
3. **Analyze** test case coverage
4. **Explore** VIVIDUS story writing guidelines
5. **Generate** VIVIDUS stories & Summary report

---

## Step 1: Retrieve test cases

Test cases can be provided in two ways — extract from whichever source the user supplies:

### Source A: CSV File

When the user attaches or references a `.csv` file, parse it as follows:

1. **Read** the file using the `read_file` tool (use the absolute path from the attachment or user prompt)
2. **Parse** the CSV — the expected columns are:

| Column | Description |
|--------|-------------|
| `id` | Test case ID (e.g. `TC-K7M2P9`) |
| `name` | Human-readable test case title |
| `source` | Reference URL (requirement link) |
| `type` | Test type (`positive`, `negative`, `configuration`, etc.) |
| `tags` | Pipe-separated tags (e.g. `creating-parts\|initial-stock`) |
| `steps` | Full test steps and expected results as a single multi-line string |

3. **Select** the test case(s) to automate based on the user's instruction (e.g. "first test case", "all", specific ID). If the user says "first test case", take only the first row. If the user says "all", process each row sequentially.
4. **Map** each CSV row to the internal test case structure:
   - `id` → `@testCaseId` meta tag
   - `source` → `@requirementId` meta tag (use the URL as-is)
   - `tags` → `@feature` meta tag (use the first tag segment before `|`)
   - `steps` field contains both the test steps AND the expected result — parse the `Given`/`When`/`Then` lines to extract the flow

### Source B: Inline prompt

When no CSV is provided, extract test case(s) directly from the user's prompt text.

Each test case **must** contain:
- **Test Steps**: Numbered, sequential actions to perform
- **Expected Results**: Clear, verifiable outcomes for each step or the entire test

**ABORT** further execution if:
- No CSV file and no inline test case text is provided
- Test steps are missing or not provided
- Expected results are not defined
- Input does not represent a valid test case structure

When aborting, explain what is missing and request a complete test case.

---

## Step 2: Execute test cases

Use Playwright MCP to execute test cases and collect element locators for VIVIDUS story generation in Step 4.

### ⚠️ MANDATORY Execution Order — Data Setup FIRST

**CRITICAL RULE**: Before performing ANY verification or navigation to the page under test, you **MUST** complete ALL test data creation steps first. Execution follows this strict phased order:

#### Phase 1: Analyze test data requirements
Before touching the browser, read ALL test case steps and identify every piece of data that must exist:
- Infrastructure data: locations, categories, warehouses, companies, etc.
- Domain data: parts, stock items, orders, BOMs, etc.
- Relationships: part → stock items → locations, part → category, etc.
- Special states: statuses (Damaged, Attention), permissions, settings, etc.

Document the **full dependency graph** before proceeding.

#### Phase 2: Create ALL test data via UI (in dependency order)
Execute ALL `Given` steps through the UI in dependency order:
1. **First**: Create independent entities (locations, categories, companies — things with no dependencies)
2. **Second**: Create dependent entities (parts that need categories, stock items that need parts + locations)
3. **Third**: Set states/statuses (mark items as Damaged, configure settings, assign permissions)

**DO NOT** navigate to the page under test or perform ANY `When`/`Then` step until ALL data exists.

#### Phase 3: Execute test actions and verifications
Only after ALL test data is confirmed created:
1. Navigate to the page under test
2. Perform `When` actions
3. Verify `Then` expectations

**VIOLATION**: Navigating to the Stock tab, Part detail page, or any verification target before all required parts, locations, stock items, and statuses are fully created via UI is a **hard violation** of this rule.

### Execution process

1. **Navigate**: `browser_navigate(url)` - URL from test case or user prompt

2. **For each test step**:
   - **DO NOT take screenshots**, use `browser_snapshot()` to take a page snapshot to understand page structure and its elements
   - Identify key elements from test cases e.g. form fields, interactive elements, visual components etc. and document their refs, text content and labels, states
   - Collect stable locator attributes: IDs, data-testid, aria-labels, exact button/link text
   - Perform actions to verify element behaviors: `browser_click`, `browser_type`, `browser_select_option`, or `browser_run_code`
   - Document any differences from expected results or any missing or changed elements

3. **Dynamic content**: `browser_wait_for(text)` for async operations

### Assumption Handling

When encountering unclear steps in test cases, or when blocked the agent should:
1. Proceed with reasonable assumption or workaround
2. Document assumption or workaround clearly
3. Flag for user validation in summary report

Example assumptions:
| Situation | Assumption Made |Marked As |
|-----------|-----------------|-----------|
| Button text unclear in TC | Used actual text from app exploration | 🔵 Assumed |
| Sort order not specified | Assumed descending by date (most recent first) | 🔵 Assumed |
| Element locator not unique | Used more specific parent context | 🔵 Assumed |
| Expected state not defined | Assumed element should be visible and enabled | 🔵 Assumed |

### When to STOP and Ask (Do NOT Assume)

Do **NOT** proceed with assumptions in these situations. Stop execution and request clarification:

| Situation | Why Ask |
|-----------|---------|
| Authentication credentials required but not provided | Security-sensitive, cannot guess |
| Target environment URL missing or unclear | Wrong environment could cause data issues |
| Test references external dependencies (APIs, databases) not accessible | Cannot verify integration behavior |
| Expected result describes business logic that cannot be verified visually | Requires domain knowledge |
| Test case references another TC ("See TC-XXX") that is not provided | Missing context for complete execution |
| Multiple valid interpretations exist with significantly different outcomes | Assumption could invalidate entire test |

---

## Step 3: Analyze Coverage & Map to VIVIDUS

### Logic & Flow Planning
**Before choosing any steps**, write out the logical flow of the test to ensure it makes functional sense.
1. Identify the *high-level* actions (e.g., "Login", "Navigate to User Profile", "Change Password").
2. Ensure the sequence handles state changes (e.g., "Page must be reloaded after saving" or "Modal must be closed").
3. Check for specific negative scenarios: Ensure the test verifies the *fail state* (e.g., "Error message visible") and doesn't accidentally succeed if the error is missing.

### Discovery & Marking
VIVIDUS capabilities and project discovery:
1. Agent **MUST** fetch available VIVIDUS steps using `vividus_get_all_features()` command
2. Read existing resources to learn patterns and conventions:
    - `src/main/resources/story/**/*.story` — existing stories (except generated and rest_api folders)
    - `src/main/resources/steps/*.steps` — reusable composite steps
3. Lifecycle and Examples usage (transformers, data tables), scenario structure and naming, meta tags

⚠️ **Priority Rule:** Composite steps from `.steps` files take precedence over basic steps returned by the VIVIDUS tool. If a composite step exists that accomplishes the same action as a basic step, always use the composite step.

**Strict** rules to adhere:
1. **ONLY use steps returned by `vividus_get_all_features()`**, **NEVER** invent, modify, or assume steps that are not explicitly listed
2. **Preserve exact syntax** - do not modify step parameters or structure
3. **Use exact locator strategies**: `cssSelector`, `xpath`, `id`, `caseInsensitiveText`, `name`
4. **If a required step is NOT available** - DO NOT silently ignore, mark as `[MISSING STEP]`
5. **🚫 NO API CALLS EVER** — Using REST API, HTTP requests, or any backend calls to create test data or verify state is **strictly forbidden**. All test data **MUST** be created exclusively through the UI. This rule has no exceptions.

### Coverage Mapping

In summary report for each test case step, assess coverage status and notes:

| TC Step | Action | Status | Notes |
|---------|--------|--------|-------|
| 1 | Log in as Global Admin | ✅ Covered | Requires navigation + cookie/auth handling |
| 2 | Navigate to Companies page | ✅ Covered | Click + wait for page load |
| 3 | Verify tooltip on hover | ⚠️ Gap | No tooltip verification step in VIVIDUS |
| 4 | Drag item to new position | ✅ Covered | Single drag-and-drop step available |
| 5 | Verify sorting order | 🔵 Assumed | Unclear if alphabetical or by date |
| 6 | Check error message style | ❌ Discrepancy | Expected red text, actual is orange |

### Coverage Status Legend
- ✅ **Covered** - Can be implemented with available VIVIDUS steps
- ⚠️ **Gap** - No VIVIDUS step available, manual intervention needed
- ❌ **Discrepancy** - Expected behavior differs from actual
- 🔵 **Assumed** - Input was unclear or incomplete; a best-guess decision was made (requires validation)

## Step 4: VIVIDUS Story Guidelines

### General rules

1. **Step Syntax:** Use exact step syntax from VIVIDUS definitions or composite steps
2. **Locators:** Follow the **Strict Hierarchy** below to ensure stability.
3. **Data Tables:** Use Examples blocks for parameterized scenarios
4. **Composite Steps:** Reuse existing composite steps; propose new ones for repeated patterns
5. **Contextual Steps:** When using parent element context, ensure child locators are relative
6. **Story Independence (CRITICAL):** Every story **MUST** be fully self-contained. Stories run in non-deterministic order and cannot share state.
   - **NEVER** reference parts, categories, stock items, or any other data created by another story
   - **NEVER** assume pre-seeded or pre-existing data (e.g., hardcoded IDs, assumed part names)
   - **ALWAYS** create all required test data via UI steps within the same scenario
   - Append the test case ID (e.g., `TC-XXXXX`) to all created entity names to guarantee uniqueness and traceability (e.g., `Resistor 10k TC-A3F8K1`)
7. **🚫 UI-ONLY TEST DATA (ABSOLUTE RULE):** Test data creation via REST API, HTTP steps, or any non-UI mechanism is **completely forbidden**.
   - **NEVER** use `When I execute HTTP POST/PUT/DELETE request` to seed data
   - **NEVER** call InvenTree API endpoints directly to create parts, stock items, locations, or any entities
   - **ALWAYS** navigate through the application UI to create every piece of required test data
   - If creating data via UI seems complex, find the UI path — **do NOT fall back to API**
8. **📋 DATA-FIRST Story Structure (MANDATORY):** Every scenario **MUST** follow this strict ordering:
   - **FIRST BLOCK — Data Setup**: ALL `Given` preconditions (create locations, categories, parts, stock items, set statuses) must come BEFORE any navigation to the page under test
   - **SECOND BLOCK — Test Actions**: `When` steps (navigate to page, click tabs, interact with elements)
   - **THIRD BLOCK — Verifications**: `Then` assertions and visual baselines
   - **NEVER** interleave verification steps with data creation steps
   - **NEVER** navigate to the test target page before ALL required test data is fully created

### Locator Stability Hierarchy
When identifying elements, you **MUST** prefer locators in this order:

1.  🥇 **Exquisite**: `data-testid`, `data-test`, `data-qa`
2.  🥈 **High**: `id` (ONLY if it looks human-readable and stable, e.g., `#submit-btn`. REJECT auto-generated IDs like `#ember123`)
3.  🥉 **Medium**: `buttonName()` or `linkText()` (Semantic and readable)
4.  ⚠️ **Low**: `caseInsensitiveText()` or `formName/fieldName` (Use with caution for localization)
5.  ⛔ **Last Resort**: `cssSelector` or `xpath` (Only if NO other option exists. XPath must be robust, avoiding indexing like `div[3]/span[2]`)

### Avoid Redundant Verifications

Do NOT verify the same element/text twice. If you wait for an element, it's already verified.

❌ **Bad** - redundant check:
```gherkin
When I wait until element located by `caseInsensitiveText(My Account)` appears
Then text `My Account` exists
```

✅ **Good** - single verification:
```gherkin
When I wait until element located by `caseInsensitiveText(My Account)` appears
```

### Use Visual Testing for Multiple Element Verification

**MANDATORY RULE**: When verifying **2 or more** elements on a page (text labels, buttons, fields, tab names, list items, etc.), you **MUST** use visual baseline testing instead of individual element checks. **Never write more than 1 individual `Then text` or `Then number of elements` assertion in a row.**

**Why**: Visual testing is more efficient, catches unexpected UI changes, and verifies element states (enabled/disabled, selected, etc.) that individual text checks cannot capture.

❌ **Bad** - verifying each element individually (even just 2):
```gherkin
Then text `Back to Home` exists
Then text `Add Account` exists
```

❌ **Bad** - verifying 3+ elements individually:
```gherkin
Then text `Back to Home` exists
Then text `Add Account` exists
Then number of elements found by `xpath(//input[@placeholder='Name'])` is equal to `1`
Then text `Upload logo` exists
Then number of elements found by `buttonName(Save)` is equal to `1`
```

✅ **Good** - visual baseline captures entire page state:
```gherkin
When I establish baseline with name `my-add-account-page`
```

**When to use visual testing**:
- ✅ Verifying 2 or more elements on the page (text labels, tabs, list rows, form fields, buttons)
- ✅ Verifying page layout, structure, and element states (enabled/disabled, selected, etc.)
- ❌ Single element verification after a navigation or action (use `When I wait until element ... appears` instead)
- ❌ Dynamic content that changes on every run (timestamps, generated IDs)

### Prefer buttonName Locator for Buttons

When interacting with button HTML elements, use `buttonName` locator instead of xpath.

❌ **Bad** - verbose xpath:
```gherkin
When I click on element located by `xpath(//button[contains(text(),'Save')])`
```

✅ **Good** - clean buttonName locator:
```gherkin
When I click on element located by `buttonName(Save)`
```

### Synchronize After Navigation

**CRITICAL RULE**: When navigating to a new page or opening a new tab, **ALWAYS** add a wait step for FIRST **interactive element** on that page or tab. This ensures the page has fully loaded and all subsequent interactive elements are available.

**Why**: Waiting for the first interactive element on a page guarantees that:
- The page DOM is fully rendered
- JavaScript has executed and initialized components
- All form fields, buttons, and other interactive elements are ready
- Subsequent steps won't fail due to elements not being available yet

✅ **Good** - wait for first interactive element after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
When I wait until element located by `caseInsensitiveText(Create Product)` appears

!-- Now safe to interact with form fields without additional waits
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

❌ **Bad** - no synchronization after navigation:
```gherkin
When I click on element located by `buttonName(Add Product)`
!-- Missing wait - next step may fail if page hasn't loaded
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
```

❌ **Bad** - waiting before every field (unnecessary):
```gherkin
When I click on element located by `buttonName(Create Product)`
When I wait until element located by `xpath(//input[@name='name'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@name='name'])`
When I wait until element located by `xpath(//input[@placeholder='URL'])` appears
When I enter `${campaignName}` in field located by `xpath(//input[@placeholder='URL'])`
```

**When to wait:**
- ✅ After clicking navigation links (new page loads)
- ✅ After clicking buttons that open new tabs or modals
- ✅ After dropdown selections that dynamically load/show new fields
- ✅ After form submissions that redirect to different pages
- ❌ Before every field on the same page (only first element needed)
- ❌ Between consecutive actions on already-loaded elements

## Step 5: Generate VIVIDUS story & Summary report

### Output Folder Structure
Create a new folder for each test case in project root for user review:

```
src/main/resources/story/generated/TC-XXXXX-[TestName]/
├── [TestName].story          # VIVIDUS story file
├── test-data/                # Generated test data (images, files, etc.)
│   └── [any required files]
└── summary.md                # Coverage report and findings
```

User will review and move story files to appropriate place after approval.

**DO NOT create:**
- Quick start guides
- README files
- Additional documentation
- Any other markdown files beyond mentioned ones

### Output Files

#### File 1: VIVIDUS Story
**Location**: `src/main/resources/story/generated/TC-XXXXX-[TestName]/[TestName].story`

```gherkin
Meta:
    @testCaseId [Test Case ID]
    @requirementId [Requirement Id]
    @feature [Feature]
    @priority [0|1|2|3|4]

Scenario: [Descriptive scenario name]
[Steps using ONLY available VIVIDUS syntax]

!-- [MISSING STEP] Comment for any gaps
!-- [ASSUMPTION] Comment for any assumptions made - REQUIRES VALIDATION
```

**Meta Tag Guidelines:**
| Tag | Values | Description |
|-----|--------|-------------|
| `@testCaseId` | `TC-XXXXX` | Exact TestRail/Jira ID (e.g., `TC-12345`) |
| `@requirementId` | `REQ-XXXXX` | Linked requirement/user story ID |
| `@feature` | Feature name | Should match feature folder or test suite |
| `@priority` | `1` \| `2` \| `3` \| `4` \| `5` | 1=Blocker, 2=Critical, 3=Major, 4=Minor, 5=Trivial |

**Assumption Comments in Story:**
```gherkin
!-- [ASSUMPTION] TC step said "click submit" but button text is "Save" - using "Save"
When I click on element located by `xpath(//button[text()='Save'])`

!-- [ASSUMPTION] TC doesn't specify wait time, assuming 10 seconds max
When I wait until element located by `caseInsensitiveText(Success)` appears in `PT10S`
```

**Scenario Mapping:**
- One test case typically maps to one scenario
- Use Examples tables to consolidate similar test cases with different data
- Split complex test cases into multiple focused scenarios if needed

#### File 2: Summary Report
**Location**: `src/main/resources/story/generated/TC-XXXXX-[TestName]/summary.md`

Summary report structure

```markdown
# Test Case [ID] - Summary

## Test Information
- **Test Case ID**: [Test case Id]
- **Title**: [Test case title]
- **Execution Date**: [Date]
- **Status**: [PASSED | PASSED WITH GAPS | FAILED]

## Coverage Report

| # | Test Case Step | Expected Result | Actual Result | Status | Notes |
|---|----------------|-----------------|---------------|--------|-------|
| 1 | [Step description] | [Expected] | [Actual observed] | ✅/⚠️/❌/🔵 | [Implementation notes or gaps] |
| 2 | ... | ... | ... | ... | ... |

**Status Legend**: ✅ Covered | ⚠️ Gap | ❌ Discrepancy | 🔵 Assumed

### Coverage Summary
- **Total Steps**: X
- **Fully Covered**: X (✅)
- **Gaps (Missing Steps)**: X (⚠️)
- **Discrepancies**: X (❌)
- **Assumed**: X (🔵)
- **Coverage Percentage**: X%

## Discrepancies Found

### [Issue Title]
- **Step #**: X
- **Expected**: [What test case says]
- **Actual**: [What was observed]
- **Impact**: [High | Medium | Low]
- **Recommendation**: [Action needed]

## Missing VIVIDUS Steps

List any actions that cannot be automated with available steps:

| Action Needed | Workaround | Priority |
|---------------|------------|----------|
| [Action] | [Possible workaround or "None"] | [High/Medium/Low] |

## Assumptions Made

**IMPORTANT: Review all assumptions below and validate they match intended behavior.**

| Step # | Original TC Instruction | Assumption Made | Rationale | Needs Validation |
|--------|------------------------|-----------------|-----------|------------------|
| X | [What TC said] | [What was assumed] | [Why this assumption] | ⚠️ YES |
```

#### File 3: Test Data (if needed)
**Location**: `src/main/resources/story/generated/TC-XXXXX-[TestName]/test-data/`
- Upload images, JSON files, or any test data generated during exploration
- Reference in story using relative path: `test-data/[filename]`

---

## Quality Checklist

### Step Compliance
- [ ] All steps exist in VIVIDUS definitions or composite steps
- [ ] Exact VIVIDUS syntax preserved (no modifications)
- [ ] Valid locator strategies: `xpath`, `cssSelector`, `caseInsensitiveText`, `id`, `name`
- [ ] Missing steps marked with `[MISSING STEP]` and ⚠️ warning

### Locator Quality
- [ ] Element text extracted exactly as displayed (preserve case)
- [ ] Locators are specific (no ambiguous matches)
- [ ] Dynamic content handled with waits

### Coverage
- [ ] Every test case step mapped to VIVIDUS step(s) or marked as gap
- [ ] Coverage percentage calculated
- [ ] Discrepancies documented with impact and recommendations

### Output Quality
- [ ] Meta tags: testCaseId, feature, priority
- [ ] Assumptions marked with `[ASSUMPTION]` comments
- [ ] Discrepancies marked with `[DISCREPANCY]` comments
- [ ] Items requiring validation clearly listed
- [ ] All report sections completed
