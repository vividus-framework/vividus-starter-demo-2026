Meta:
    @testCaseId TC-JIVR5Z
    @requirementId https://docs.inventree.org/en/latest/part/#part-category
    @feature parts
    @priority 2

Scenario: Part category list shows sub-categories underneath the current category
When I login to web app with username `${username}` and password `${password}`

!-- Create parent category 'Electronics TC-JIVR5Z' from the root Part Categories tab
When I go to relative URL `/web/part/category/index/subcategories`
When I wait until element located by `name(action-button-add-part-category)` appears
When I click on element located by `name(action-button-add-part-category)`
When I wait until element located by `name(text-field-name)` appears
When I enter `Electronics TC-JIVR5Z` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Electronics TC-JIVR5Z)` appears

!-- Navigate into Electronics category subcategories tab
When I open subcategories tab

!-- Add subcategory 'Passive'
When I click on element located by `name(action-button-add-part-category)`
When I wait until element located by `name(text-field-name)` appears
When I enter `Passive` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Passive)` appears

!-- Add subcategory 'Active'
When I click on element located by `name(action-button-add-part-category)`
When I wait until element located by `name(text-field-name)` appears
When I enter `Active` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Active)` appears

!-- Add subcategory 'Connectors'
When I click on element located by `name(action-button-add-part-category)`
When I wait until element located by `name(text-field-name)` appears
When I enter `Connectors` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`

!-- Verify all three subcategories are listed (3+ elements → visual baseline)
When I wait until element located by `caseInsensitiveText(Connectors)` appears
When I establish baseline with name `subcategories`
