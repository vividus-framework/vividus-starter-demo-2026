Meta:
    @testCaseId TC-K7M2P9
    @requirementId https://docs.inventree.org/en/latest/part/create/#initial-stock
    @feature creating-parts
    @priority 2

Scenario: Create part with initial stock by checking the Create Initial Stock checkbox
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I create part with name `Capacitor 100nF` and initial stock quantity `50`

When I establish baseline with name `capacitor-details`

When I open stock tab

When I change context to element located `xpath(//tr[contains(@class, 'mantine-datatable-row')])`
When I establish baseline with name `capacitor-stock`
When I reset context
