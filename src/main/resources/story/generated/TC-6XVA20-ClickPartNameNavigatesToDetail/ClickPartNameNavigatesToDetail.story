Meta:
    @testCaseId TC-6XVA20
    @requirementId https://docs.inventree.org/en/latest/part/#part-category
    @feature parts
    @priority 2

Scenario: Clicking a part name in the category list navigates to the Part Detail view
When I login to web app with username `${username}` and password `${password}`

!-- Create a dedicated part for this test so the story is self-contained
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Resistor 10k TC-6XVA20` in field located by `name(text-field-name)`
When I click on element located by `buttonName(Submit)`

!-- Return to parts list and click the part name link
When I navigate to parts list
When I wait until element located by `caseInsensitiveText(Resistor 10k TC-6XVA20)` appears
When I click on element located by `caseInsensitiveText(Resistor 10k TC-6XVA20)`

!-- Verify the browser navigated to the Part Detail view
When I wait until element located by `caseInsensitiveText(Part: Resistor 10k TC-6XVA20)` appears
