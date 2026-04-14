Meta:
    @testCaseId TC-D6N2R7
    @requirementId https://docs.inventree.org/en/latest/part/create/#create-part-form
    @feature creating-parts
    @priority 3

Scenario: Submit Create Part form with missing required Name field shows validation error
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears

!-- Leave Name field empty and click Submit
When I click on element located by `buttonName(Submit)`

!-- Verify the name input is flagged as invalid
Then number of elements found by `xpath(//input[@aria-label='text-field-name' and @aria-invalid='true'])` is equal to `1`
Then text `This field is required.` exists
