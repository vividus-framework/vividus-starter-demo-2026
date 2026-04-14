Meta:
    @testCaseId TC-XNI8V2
    @requirementId https://docs.inventree.org/en/latest/part/#units-of-measure
    @feature parts
    @priority 3

Scenario: Part with blank unit of measure is tracked in dimensionless pieces
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Generic Component TC-XNI8V2` in field located by `name(text-field-name)`

!-- Leave Units field empty (default state)
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Generic Component TC-XNI8V2)` appears

!-- Open Edit form and verify the units field is blank (dimensionless = pcs)
When I click on element located by `name(action-menu-part-actions)`
When I wait until element located by `name(action-menu-part-actions-edit)` appears
When I click on element located by `name(action-menu-part-actions-edit)`
When I wait until element located by `name(text-field-units)` appears

!-- [ASSUMPTION] Units field value is empty string when dimensionless (tracked as pcs)
Then number of elements found by `xpath(//input[@aria-label='text-field-units' and @value=''])` is equal to `1`
