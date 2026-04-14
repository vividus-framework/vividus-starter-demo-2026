Scenario: Verify PUT /api/company/price-break/{id}/ updates a price break
Meta:
@api
@apiVersion 479
@endpoint PUT /api/company/price-break/{id}/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create prerequisite supplier company
Given I initialize scenario variable `companyName` with value `#{generate(Company.name)} #{generate(regexify '[a-z]{5}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${companyName}", "currency": "USD", "is_supplier": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `supplierId`
!-- Get a valid part ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `partId`
!-- Create a supplier part
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "supplier": ${supplierId}, "SKU": "#{generate(regexify '[A-Z]{3}-[0-9]{6}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `supplierPartId`
!-- Create a price break to update
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${supplierPartId}, "quantity": 10, "price": "99.99", "price_currency": "USD"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/price-break/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `priceBreakId`
!-- Update with PUT
Given I initialize scenario variable `updatedQuantity` with value `#{randomInt(50, 200)}`
Given I initialize scenario variable `updatedPrice` with value `#{randomInt(1, 500)}.#{generate(numerify '##')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${supplierPartId}, "quantity": ${updatedQuantity}, "price": "${updatedPrice}", "price_currency": "EUR"}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/company/price-break/${priceBreakId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.price_currency` is equal to `EUR`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/price-break/${priceBreakId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/part/${supplierPartId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${supplierId}/`
Then response code is equal to `204`
