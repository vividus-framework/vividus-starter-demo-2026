Meta:
    @testCaseId TC-X4R1N6
    @requirementId https://docs.inventree.org/en/latest/part/create/#initial-stock
    @feature creating-parts
    @priority 3

Scenario: Create Initial Stock section is hidden when Create Initial Stock setting is disabled
When I login to web app with username `${username}` and password `${password}`

!-- Precondition: ensure the Create Initial Stock global setting is DISABLED
When I open parts system settings
When I find <= `1` elements by `xpath(//input[@aria-label='toggle-setting-PART_CREATE_INITIAL' and @data-checked='true'])` and for each element do
|step|
|When I click on element located by `name(setting-PART_CREATE_INITIAL-wrapper)`|

!-- Navigate to Parts view
When I go to relative URL `/web/part/category/index/parts`
When I wait until element located by `name(action-menu-add-parts)` appears

!-- Open Add Parts dropdown and select Create Part
When I open create part form

!-- Wait for the Add Part dialog to open
When I wait until element located by `name(text-field-name)` appears

!-- Verify the Initial Stock section does NOT appear
Then number of elements found by `caseInsensitiveText(Initial Stock)` is equal to `0`
