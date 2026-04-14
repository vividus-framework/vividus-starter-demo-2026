Scenario: Verify GET /api/company/part/ returns paginated list of supplier parts
Meta:
@api
@apiVersion 479
@endpoint GET /api/company/part/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/company/part/?limit=10`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.count` is greater than or equal to `0`

Scenario: Verify GET /api/company/part/{id}/ returns a single supplier part
Meta:
@api
@apiVersion 479
@endpoint GET /api/company/part/{id}/
@responseCode 200
!-- Create prerequisite company (supplier) and supplier part
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
Given I initialize scenario variable `sku` with value `#{generate(regexify '[A-Z]{3}-[0-9]{6}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "supplier": ${supplierId}, "SKU": "${sku}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `supplierPartId`
!-- Retrieve the supplier part by ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/company/part/${supplierPartId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${supplierPartId}`
Then JSON element value from `${response}` by JSON path `$.SKU` is equal to `${sku}`
!-- Cleanup
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
