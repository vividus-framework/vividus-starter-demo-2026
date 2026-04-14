Meta:
    @testCaseId TC-8PZKPR
    @requirementId https://docs.inventree.org/en/latest/part/views/#stock
    @feature part-views
    @priority 2

Scenario: Stock tab displays all stock items with location and status
When I login to web app with username `${username}` and password `${password}`
When I navigate to parts list
When I open create part form
When I wait until element located by `name(text-field-name)` appears
When I enter `Resistor 10k TC-8PZKPR` in field located by `name(text-field-name)`

!-- Add first stock item inline (quantity 100)
When I clear field located by `name(number-field-initial_stock.quantity)`
When I enter `100` in field located by `name(number-field-initial_stock.quantity)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `caseInsensitiveText(Resistor 10k TC-8PZKPR)` appears

!-- Open Stock tab and add a second stock item (quantity 50)
When I open stock tab
When I click on element located by `name(action-button-add-stock-item)`
When I wait until element located by `name(number-field-quantity)` appears
When I clear field located by `name(number-field-quantity)`
When I enter `50` in field located by `name(number-field-quantity)`
When I click on element located by `buttonName(Submit)`
When I wait until element located by `tagName(table)` appears

!-- Verify the stock table has two rows with quantities
Then number of elements found by `xpath(//table//tbody/tr)` is greater than `1`
Then text `100` exists
Then text `50` exists
When I establish baseline with name `TC-8PZKPR-stock-tab`
