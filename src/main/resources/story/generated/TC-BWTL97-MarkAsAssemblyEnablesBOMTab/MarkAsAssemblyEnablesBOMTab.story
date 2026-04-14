Meta:
    @testCaseId TC-BWTL97
    @requirementId https://docs.inventree.org/en/latest/part/#assembly
    @feature parts
    @priority 2

Scenario: Mark a part as Assembly enables BOM tab
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Controller Board TC-BWTL97` in field located by `name(text-field-name)`

!-- Leave Assembly unchecked (it is off by default) and submit
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Controller Board TC-BWTL97)` appears

!-- Verify BOM tab is NOT present before editing
Then number of elements found by `xpath(//a[contains(@href,'/bom')])` is equal to `0`

!-- Open Edit form via part-actions menu
When I click on element located by `name(action-menu-part-actions)`
When I wait until element located by `name(action-menu-part-actions-edit)` appears
When I click on element located by `name(action-menu-part-actions-edit)`
When I wait until element located by `name(boolean-field-assembly)` appears

!-- Enable the Assembly checkbox and submit
When I click on element located by `name(boolean-field-assembly)`
When I click on element located by `buttonName(Submit)`

!-- Verify BOM tab is now present after marking as Assembly
When I wait until element located by `xpath(//a[contains(@href,'/bom')])` appears
Then number of elements found by `xpath(//a[contains(@href,'/bom')])` is equal to `1`
