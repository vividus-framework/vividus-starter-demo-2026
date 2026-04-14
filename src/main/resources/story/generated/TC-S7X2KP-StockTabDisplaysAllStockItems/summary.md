# Test Case TC-S7X2KP - Summary

## Test Information
- **Test Case ID**: TC-S7X2KP
- **Title**: Stock tab displays all stock items for a part with quantity, location and status
- **Execution Date**: 2026-04-14
- **Status**: PASSED WITH GAPS

## Coverage Report

| # | Test Case Step | Expected Result | Actual Result | Status | Notes |
|---|----------------|-----------------|---------------|--------|-------|
| 1 | Given a part 'Capacitor 100uF' exists with two stock items: one at 'Shelf A1' qty 50 status 'OK', one at 'Shelf B2' qty 10 status 'Damaged' | Test data created via UI | Two stock locations and one part created via UI; two stock items added with correct quantities, locations, and statuses confirmed | ✅ Covered | Data setup done through UI; entity names suffixed with TC-S7X2KP for uniqueness |
| 2 | Given a user with view permission is logged in | Logged in as admin | Admin login via composite step `When I login to web app` | ✅ Covered | 🔵 Admin user used (has view permissions); test case does not specify a separate view-only user |
| 3 | When the user navigates to the part detail page for 'Capacitor 100uF' and clicks the 'Stock' tab | Stock tab shown | Navigated via Parts list, part created during test; stock tab opened via composite step `When I open stock tab` | ✅ Covered | Navigation follows create-part flow as part must be created first |
| 4 | Then the Stock table displays a row for location 'Shelf A1' with quantity '50' and status 'OK' | Row visible | Visual baseline captures entire stock table including both rows | ✅ Covered | Visual baseline used per guidelines (2+ element verification) |
| 5 | Then the Stock table displays a row for location 'Shelf B2' with quantity '10' and status 'Damaged' | Row visible | Same visual baseline covers this row | ✅ Covered | Visual baseline used per guidelines (2+ element verification) |

**Status Legend**: ✅ Covered | ⚠️ Gap | ❌ Discrepancy | 🔵 Assumed

### Coverage Summary
- **Total Steps**: 5
- **Fully Covered**: 5 (✅)
- **Gaps (Missing Steps)**: 0 (⚠️)
- **Discrepancies**: 0 (❌)
- **Assumed**: 1 (🔵)
- **Coverage Percentage**: 100%

## Discrepancies Found

None.

## Missing VIVIDUS Steps

None. All test steps are covered by available VIVIDUS steps and composite steps.

## Assumptions Made

**IMPORTANT: Review all assumptions below and validate they match intended behavior.**

| Step # | Original TC Instruction | Assumption Made | Rationale | Needs Validation |
|--------|------------------------|-----------------|-----------|------------------|
| 2 | "a user with view permission is logged in" | Admin user (credentials from `${username}`/`${password}` properties) used | No separate view-only user account is configured; admin has view permissions | ⚠️ YES — If test requires a non-admin user with explicit view-only permission, a separate user must be provisioned and credentials added to properties |

## Implementation Notes

### Story Structure
The story follows the DATA-FIRST ordering:
1. **Phase 1**: Create two stock locations (`Shelf A1 TC-S7X2KP`, `Shelf B2 TC-S7X2KP`)
2. **Phase 2**: Create the part (`Capacitor 100uF TC-S7X2KP`)
3. **Phase 3**: Add two stock items via the Stock tab Add Stock Item dialog
4. **Phase 4**: Navigate to the Stock tab and capture a visual baseline to verify both rows

### Locators Used
| Element | Locator Strategy | Locator Value |
|---------|-----------------|---------------|
| Add Stock Location button | `name` | `action-button-add-stock-location` |
| Location Name field | `name` | `text-field-name` |
| Add Stock Item button | `name` | `action-button-add-stock-item` |
| Quantity field | `name` | `number-field-quantity` |
| Location combobox | `name` | `related-field-location` |
| Location dropdown option | `xpath` | `//div[@role='option'][contains(.,'<location>')]` |
| Status choice field | `name` | `choice-field-status_custom_key` |
| Damaged status option | `xpath` | `//div[@role='option'][contains(.,'Damaged')]` |

### Composite Steps Reused
- `When I login to web app with username ... and password ...`
- `When I navigate to parts list`
- `When I open create part form`
- `When I open stock tab`
