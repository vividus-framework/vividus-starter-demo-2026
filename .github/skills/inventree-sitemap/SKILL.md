---
name: inventree-sitemap
description: "Provides the InvenTree demo application sitemap. Use when: automating UI tests, navigating InvenTree pages, generating test stories for InvenTree, finding URLs for Parts, Stock, Manufacturing, Purchasing or Sales sections."
---

# InvenTree Application Sitemap

**Base URL:** `http://inventree.localhost/`  
**Login:** `http://inventree.localhost/web/login` (credentials: `admin` / `admin`)

---

## Top-Level Navigation

| Section | URL | Description |
|---------|-----|-------------|
| Dashboard | `/web/home` | Overview widgets, news updates |
| Parts | `/web/part` | Part catalogue and categories |
| Stock | `/web/stock` | Stock locations and items |
| Manufacturing | `/web/manufacturing` | Build orders |
| Purchasing | `/web/purchasing` | Purchase orders, suppliers, manufacturers |
| Sales | `/web/sales` | Sales orders, shipments, return orders, customers |

---

## Parts (`/web/part`)

Lands at: `/web/part/category/index/details`

### Part Category Index Tabs

| Tab | URL |
|-----|-----|
| Category Details | `/web/part/category/index/details/details` |
| Part Categories | `/web/part/category/index/details/subcategories` |
| Parts | `/web/part/category/index/details/parts` |

### Creating a New Part

Navigate to: `/web/part/category/index/parts`

**Steps:**
1. Click button `name(action-menu-add-parts)` — opens the Add Parts dropdown menu
2. Click menuitem `name(action-menu-add-parts-create-part)` — opens the Create Part dialog
3. Wait for `caseInsensitiveText(Initial Stock)` to confirm dialog is open

**Create Part dialog fields:**

| Field | Locator | Notes |
|-------|---------|-------|
| Part Name (required) | `name(text-field-name)` | Free text |
| IPN | `name(text-field-IPN)` | Internal Part Number |
| Description | `name(text-field-description)` | Free text |
| Revision | `name(text-field-revision)` | Free text |
| Keywords | `name(text-field-keywords)` | Free text |
| Units | `name(text-field-units)` | Free text |
| Link | `name(text-field-link)` | External URL |
| Minimum Stock | `name(number-field-minimum_stock)` | Default: 0 |
| Category | `name(related-field-category)` | Combobox search |
| Revision Of | `name(related-field-revision_of)` | Combobox search |
| Variant Of | `name(related-field-variant_of)` | Combobox search |
| Default Location | `name(related-field-default_location)` | Combobox search |
| Responsible | `name(related-field-responsible)` | Combobox search |
| Component | `name(boolean-field-component)` | Switch (default: on) |
| Assembly | `name(boolean-field-assembly)` | Switch (default: off) |
| Is Template | `name(boolean-field-is_template)` | Switch (default: off) |
| Testable | `name(boolean-field-testable)` | Switch (default: off) |
| Trackable | `name(boolean-field-trackable)` | Switch (default: off) |
| Purchaseable | `name(boolean-field-purchaseable)` | Switch (default: on) |
| Salable | `name(boolean-field-salable)` | Switch (default: off) |
| Virtual | `name(boolean-field-virtual)` | Switch (default: off) |
| Locked | `name(boolean-field-locked)` | Switch (default: off) |
| Active | `name(boolean-field-active)` | Switch (default: on) |
| Initial Stock Quantity | `name(number-field-initial_stock.quantity)` | Default: 0 |
| Initial Stock Location | `name(related-field-initial_stock.location)` | Combobox search |

**Submit:** Click `buttonName(Submit)`  
**Wait for success:** `caseInsensitiveText(Item Created)`  
**Wait for dismiss:** wait until `caseInsensitiveText(Item Created)` disappears

---

### Individual Part Page — `/web/part/<id>/details`

All parts have these tabs:

| Tab | URL suffix |
|-----|------------|
| Part Details | `.../details` |
| Stock | `.../stock` |
| Allocations | `.../allocations` |
| Used In | `.../used_in` |
| Part Pricing | `.../pricing` |
| Suppliers | `.../suppliers` |
| Purchase Orders | `.../purchase_orders` |
| Stock History | `.../stocktake` |
| Related Parts | `.../related_parts` |
| Parameters | `.../parameters` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

Assembly parts additionally show:

| Tab | URL suffix |
|-----|------------|
| Bill of Materials | `.../bom` |
| Build Orders | `.../builds` |

---

## Stock (`/web/stock`)

Lands at: `/web/stock/location/index/details`

### Stock Location Index Tabs

| Tab | URL |
|-----|-----|
| Location Details | `/web/stock/location/index/details/details` |
| Stock Locations | `/web/stock/location/index/details/sublocations` |
| Stock Items | `/web/stock/location/index/details/stock-items` |

### Individual Stock Item Page — `/web/stock/item/<id>/details`

| Tab | URL suffix |
|-----|------------|
| Stock Details | `.../details` |
| Stock Tracking | `.../tracking` |
| Allocations | `.../allocations` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

---

## Manufacturing (`/web/manufacturing`)

Lands at: `/web/manufacturing/index/buildorder`

### Manufacturing Index Tab

| Tab | URL |
|-----|-----|
| Build Orders | `/web/manufacturing/index/buildorder/buildorder` |

### Individual Build Order Page — `/web/manufacturing/build-order/<id>/details`

| Tab | URL suffix |
|-----|------------|
| Build Details | `.../details` |
| Required Parts | `.../line-items` |
| Allocated Stock | `.../allocated-stock` |
| Consumed Stock | `.../consumed-stock` |
| Incomplete Outputs | `.../incomplete-outputs` |
| Completed Outputs | `.../complete-outputs` |
| Test Results | `.../test-results` |
| Parameters | `.../parameters` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

---

## Purchasing (`/web/purchasing`)

Lands at: `/web/purchasing/index/purchaseorders`

### Purchasing Index Tabs

| Tab | URL |
|-----|-----|
| Purchase Orders | `/web/purchasing/index/purchaseorders/purchaseorders` |
| Suppliers | `/web/purchasing/index/purchaseorders/suppliers` |
| Supplier Parts | `/web/purchasing/index/purchaseorders/supplier-parts` |
| Manufacturers | `/web/purchasing/index/purchaseorders/manufacturer` |
| Manufacturer Parts | `/web/purchasing/index/purchaseorders/manufacturer-parts` |

### Individual Purchase Order Page — `/web/purchasing/purchase-order/<id>/details`

| Tab | URL suffix |
|-----|------------|
| Order Details | `.../detail` |
| Line Items | `.../line-items` |
| Received Stock | `.../received-stock` |
| Parameters | `.../parameters` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

### Individual Company / Supplier Page — `/web/company/<id>/details`

| Tab | URL suffix |
|-----|------------|
| Company Details | `.../details` |
| Supplied Parts | `.../supplied-parts` _(suppliers only)_ |
| Purchase Orders | `.../purchase-orders` |
| Stock Items | `.../stock-items` |
| Contacts | `.../contacts` |
| Addresses | `.../addresses` |
| Parameters | `.../parameters` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

---

## Sales (`/web/sales`)

Lands at: `/web/sales/index/salesorders`

### Sales Index Tabs

| Tab | URL |
|-----|-----|
| Sales Orders | `/web/sales/index/salesorders/salesorders` |
| Pending Shipments | `/web/sales/index/salesorders/shipments` |
| Return Orders | `/web/sales/index/salesorders/returnorders` |
| Customers | `/web/sales/index/salesorders/customers` |

### Individual Sales Order Page — `/web/sales/sales-order/<id>/details`

| Tab | URL suffix |
|-----|------------|
| Order Details | `.../detail` |
| Line Items | `.../line-items` |
| Shipments | `.../shipments` |
| Allocated Stock | `.../allocations` |
| Build Orders | `.../build-orders` |
| Parameters | `.../parameters` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

### Individual Return Order Page — `/web/sales/return-order/<id>/details`

| Tab | URL suffix |
|-----|------------|
| Order Details | `.../detail` |
| Line Items | `.../line-items` |
| Parameters | `.../parameters` |
| Attachments | `.../attachments` |
| Notes | `.../notes` |

---

## Global UI Elements

- **Search:** toolbar button `open-search` (top bar)
- **Spotlight / Quick-nav:** toolbar button `open-spotlight`
- **Barcode scan:** toolbar button `barcode-scan-button-any`
- **Notifications:** toolbar button `open-notifications`
- **User menu:** toolbar button `Adam Administrator` → profile, settings, logout

---

## UI Interaction Patterns

Key quirks to be aware of when interacting with InvenTree UI elements using Playwright.

### Dropdowns / action menus

Dropdown menus are **not rendered in the DOM until the trigger button is clicked**. After clicking the trigger, always wait for a menu item to be visible before attempting to click it.

Menu buttons and their items follow a hierarchical `aria-label` naming convention, e.g. a button `action-menu-add-parts` opens items like `action-menu-add-parts-create-part`.

### Settings toggle switches

Clicking the toggle `<input>` directly will **time out** — the switch track `<span>` overlay intercepts pointer events. Click the **wrapper element** (`aria-label="setting-<KEY>-wrapper"`) instead.

To check the current state of a toggle before interacting, read the `data-checked` attribute on the `<input>` element (`aria-label="toggle-setting-<KEY>"`).

### Number input fields

Number inputs have a pre-filled default value (commonly `0`). **Clear the field first** before typing a new value, otherwise the new value appends to the existing one.

### Accordion sections in forms

Accordion sections inside forms are **expanded by default** when they are visible. Their visibility is controlled by global system settings, not by a checkbox inside the form itself. Use the section title text to assert presence or absence.
