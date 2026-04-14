Meta:
    @testCaseId TC-A3F8K1
    @requirementId https://docs.inventree.org/en/latest/part/create/#create-part-form
    @feature creating-parts
    @priority 2

Scenario: Create a new part using the Create Part form with all required fields
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Resistor 10k-TC-A3F8K1` in field located by `name(text-field-name)`
When I enter `Standard 10kΩ resistor 0402` in field located by `name(text-field-description)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Part: Resistor 10k-TC-A3F8K1)` appears
Then text `Resistor 10k-TC-A3F8K1` exists
