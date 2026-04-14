Meta:
    @testCaseId TC-9RUHY8
    @requirementId https://docs.inventree.org/en/latest/part/views/#bill-of-materials
    @feature part-views
    @priority 2

Scenario: BOM tab is visible only for Assembly parts
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `PCB Assembly TC-9RUHY8` in field located by `name(text-field-name)`

!-- Enable the Assembly checkbox in the create form
When I click on element located by `name(boolean-field-assembly)`
When I click on element located by `buttonName(Submit)`

!-- Verify the BOM tab is present on the new part detail page
When I wait until element located by `caseInsensitiveText(PCB Assembly TC-9RUHY8)` appears
Then number of elements found by `xpath(//a[contains(@href,'/bom')])` is equal to `1`
