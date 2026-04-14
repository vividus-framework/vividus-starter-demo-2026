Meta:
    @testCaseId TC-18J7UX
    @requirementId https://docs.inventree.org/en/latest/part/revision/#revision-restrictions
    @feature revisions
    @priority 2

Scenario: Creating a circular revision reference is rejected
When I login to web app with username `${username}` and password `${password}`

!-- Precondition: ensure Part Revisions setting is enabled
When I open parts system settings
When I find <= `1` elements by `xpath(//input[@aria-label='toggle-setting-PART_ENABLE_REVISION' and not(@data-checked='true')])` and for each element do
|step|
|When I click on element located by `xpath(//input[@aria-label='toggle-setting-PART_ENABLE_REVISION']/ancestor::button)`|

!-- Create a test part via the Create Part form
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `PCB Assembly TC-18J7UX` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(PCB Assembly TC-18J7UX)` appears

!-- Open Edit form and attempt to set 'Revision Of' to the same part (circular reference)
When I click on element located by `name(action-menu-part-actions)`
When I wait until element located by `name(action-menu-part-actions-edit)` appears
When I click on element located by `name(action-menu-part-actions-edit)`
When I wait until element located by `xpath(//input[@aria-label='related-field-revision_of'])` appears
When I click on element located by `xpath(//input[@aria-label='related-field-revision_of'])`
When I enter `PCB Assembly TC-18J7UX` in field located by `xpath(//input[@aria-label='related-field-revision_of'])`
When I wait until element located by `xpath(//div[@role='option'][contains(.,'PCB Assembly TC-18J7UX')])` appears
When I click on element located by `xpath(//div[@role='option'][contains(.,'PCB Assembly TC-18J7UX')])`
When I click on element located by `buttonName(Submit)`

!-- Verify the dialog remains open (submission was rejected)
Then number of elements found by `xpath(//div[@role='dialog'])` is equal to `1`
