Meta:
    @testCaseId TC-S7X2KP
    @requirementId https://docs.inventree.org/en/latest/part/views/#stock
    @feature part-views
    @priority 2

Scenario: Stock tab displays all stock items for a part with quantity, location and status

!-- === PHASE 1: CREATE STOCK LOCATIONS ===
When I login to web app with username `${username}` and password `${password}`

!-- Create first stock location: Shelf A1 TC-S7X2KP
When I go to relative URL `/web/stock/location/index/sublocations`
When I wait until element located by `name(action-button-add-stock-location)` appears
When I click on element located by `name(action-button-add-stock-location)`
When I wait until element located by `caseInsensitiveText(Add Stock Location)` appears
When I enter `Shelf A1 TC-S7X2KP` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Shelf A1 TC-S7X2KP)` appears

!-- Create second stock location: Shelf B2 TC-S7X2KP
When I go to relative URL `/web/stock/location/index/sublocations`
When I wait until element located by `name(action-button-add-stock-location)` appears
When I click on element located by `name(action-button-add-stock-location)`
When I wait until element located by `caseInsensitiveText(Add Stock Location)` appears
When I enter `Shelf B2 TC-S7X2KP` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Shelf B2 TC-S7X2KP)` appears

!-- === PHASE 2: CREATE PART ===
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Capacitor 100uF TC-S7X2KP` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Capacitor 100uF TC-S7X2KP)` appears

!-- === PHASE 3: ADD STOCK ITEMS ===
!-- Open Stock tab and add first stock item: qty 50, location Shelf A1, status OK (default)
When I open stock tab
When I click on element located by `name(action-button-add-stock-item)`
When I wait until element located by `caseInsensitiveText(Add Stock Item)` appears
When I clear field located by `name(number-field-quantity)`
When I enter `50` in field located by `name(number-field-quantity)`
When I click on element located by `name(related-field-location)`
When I enter `Shelf A1 TC-S7X2KP` in field located by `name(related-field-location)`
When I wait until element located by `xpath(//div[@role='option'][contains(.,'Shelf A1 TC-S7X2KP')])` appears
When I click on element located by `xpath(//div[@role='option'][contains(.,'Shelf A1 TC-S7X2KP')])`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `tagName(table)` appears

!-- Add second stock item: qty 10, location Shelf B2, status Damaged
When I click on element located by `name(action-button-add-stock-item)`
When I wait until element located by `caseInsensitiveText(Add Stock Item)` appears
When I clear field located by `name(number-field-quantity)`
When I enter `10` in field located by `name(number-field-quantity)`
When I click on element located by `name(related-field-location)`
When I enter `Shelf B2 TC-S7X2KP` in field located by `name(related-field-location)`
When I wait until element located by `xpath(//div[@role='option'][contains(.,'Shelf B2 TC-S7X2KP')])` appears
When I click on element located by `xpath(//div[@role='option'][contains(.,'Shelf B2 TC-S7X2KP')])`
When I click on element located by `name(choice-field-status_custom_key)`
When I wait until element located by `xpath(//div[@role='option'][contains(.,'Damaged')])` appears
When I click on element located by `xpath(//div[@role='option'][contains(.,'Damaged')])`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `tagName(table)` appears

!-- === PHASE 4: NAVIGATE TO STOCK TAB AND VERIFY ===
When I open stock tab
When I establish baseline with name `TC-S7X2KP-stock-tab-all-items`
