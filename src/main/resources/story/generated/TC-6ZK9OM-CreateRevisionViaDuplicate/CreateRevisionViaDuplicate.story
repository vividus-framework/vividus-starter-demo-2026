Meta:
    @testCaseId TC-6ZK9OM
    @requirementId https://docs.inventree.org/en/latest/part/revision/#create-a-revision
    @feature revisions
    @priority 2

Scenario: Create a new revision via the Duplicate Part action
When I login to web app with username `${username}` and password `${password}`

!-- Precondition: ensure Part Revisions setting is enabled
When I open parts system settings
When I find <= `1` elements by `xpath(//input[@aria-label='toggle-setting-PART_ENABLE_REVISION' and not(@data-checked='true')])` and for each element do
|step|
|When I click on element located by `xpath(//input[@aria-label='toggle-setting-PART_ENABLE_REVISION']/ancestor::button)`|

!-- Create a part with revision 'A' via the Create Part form
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `PCB Assembly TC-6ZK9OM` in field located by `name(text-field-name)`
When I enter `A` in field located by `name(text-field-revision)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(PCB Assembly TC-6ZK9OM)` appears

!-- Open Duplicate action from the part-actions menu
When I click on element located by `name(action-menu-part-actions)`
When I wait until element located by `name(action-menu-part-actions-duplicate)` appears
When I click on element located by `name(action-menu-part-actions-duplicate)`
When I wait until element located by `name(text-field-name)` appears

!-- Set Revision field to 'B'
When I clear field located by `name(text-field-revision)`
When I enter `B` in field located by `name(text-field-revision)`

!-- Set 'Revision Of' to the original part
When I click on element located by `xpath(//input[@aria-label='related-field-revision_of'])`
When I enter `PCB Assembly TC-6ZK9OM` in field located by `xpath(//input[@aria-label='related-field-revision_of'])`
When I wait until element located by `xpath(//div[@role='option'][contains(.,'PCB Assembly TC-6ZK9OM')])` appears
When I click on element located by `xpath(//div[@role='option'][contains(.,'PCB Assembly TC-6ZK9OM')])`
When I click on element located by `buttonName(Submit)`

!-- Verify the new revision detail page shows Revision 'B'
When I wait until element located by `caseInsensitiveText(PCB Assembly TC-6ZK9OM)` appears
Then text `B` exists
