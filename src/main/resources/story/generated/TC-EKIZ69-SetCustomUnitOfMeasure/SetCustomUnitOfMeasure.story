Meta:
    @testCaseId TC-EKIZ69
    @requirementId https://docs.inventree.org/en/latest/part/#units-of-measure
    @feature parts
    @priority 3

Scenario: Set a custom unit of measure for a part
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Copper Wire TC-EKIZ69` in field located by `name(text-field-name)`

!-- Set Units to 'm' directly in the create form
When I enter `m` in field located by `name(text-field-units)`
When I click on element located by `buttonName(Submit)`

!-- Verify part details page now shows the unit 'm'
When I wait until element located by `caseInsensitiveText(Copper Wire TC-EKIZ69)` appears
When I establish baseline with name `TC-EKIZ69-part-details-with-units`
