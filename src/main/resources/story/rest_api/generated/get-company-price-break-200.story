Scenario: Verify GET /api/company/price-break/ returns paginated list of supplier price breaks
Meta:
@api
@apiVersion 479
@endpoint GET /api/company/price-break/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/company/price-break/?limit=10`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.count` is greater than or equal to `0`

Scenario: Verify GET /api/company/price-break/{id}/ returns a single price break
Meta:
@api
@apiVersion 479
@endpoint GET /api/company/price-break/{id}/
@responseCode 200
!-- Create prerequisite supplier company, supplier part, and price break
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
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
!-- Create a price break
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${supplierPartId}, "quantity": #{randomInt(1, 100)}, "price": "#{randomInt(1, 999)}.#{generate(numerify '##')}", "price_currency": "USD"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/price-break/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `priceBreakId`
!-- Retrieve the price break by ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/company/price-break/${priceBreakId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${priceBreakId}`
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
