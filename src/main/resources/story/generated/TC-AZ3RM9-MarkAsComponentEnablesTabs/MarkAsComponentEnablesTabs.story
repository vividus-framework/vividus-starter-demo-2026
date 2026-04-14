Meta:
    @testCaseId TC-AZ3RM9
    @requirementId https://docs.inventree.org/en/latest/part/#component
    @feature parts
    @priority 2

Scenario: Mark a part as Component makes it available in Used In and Allocated tabs
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Resistor 10k TC-AZ3RM9` in field located by `name(text-field-name)`

!-- Uncheck Component (enabled by default) and submit
When I click on element located by `name(boolean-field-component)`
When I click on element located by `name(boolean-field-purchaseable)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Resistor 10k TC-AZ3RM9)` appears

!-- Verify Used In and Allocated tabs are absent before marking as Component
Then number of elements found by `xpath(//a[contains(@href,'/used_in')])` is equal to `0`
Then number of elements found by `xpath(//a[contains(@href,'/allocations')])` is equal to `0`

!-- Open Edit form and enable the Component checkbox
When I click on element located by `name(action-menu-part-actions)`
When I wait until element located by `name(action-menu-part-actions-edit)` appears
When I click on element located by `name(action-menu-part-actions-edit)`
When I wait until element located by `name(boolean-field-component)` appears
When I click on element located by `name(boolean-field-component)`
When I click on element located by `buttonName(Submit)`

!-- Verify Used In and Allocated tabs are now visible
When I wait until element located by `xpath(//a[contains(@href,'/used_in')])` appears
Then number of elements found by `xpath(//a[contains(@href,'/used_in')])` is equal to `1`
Then number of elements found by `xpath(//a[contains(@href,'/allocations')])` is equal to `1`
