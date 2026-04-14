Scenario: Verify PATCH /api/company/address/{id}/ partially updates an address
Meta:
@api
@apiVersion 479
@endpoint PATCH /api/company/address/{id}/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create prerequisite company
Given I initialize scenario variable `companyName` with value `#{generate(Company.name)} #{generate(regexify '[a-z]{5}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${companyName}", "currency": "USD", "is_supplier": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `companyId`
!-- Create an address to partially update
Given I initialize scenario variable `addressTitle` with value `#{generate(regexify '[a-z]{10}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "${addressTitle}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `addressId`
!-- Partially update only the line1 field
Given I initialize scenario variable `updatedLine1` with value `#{generate(Address.streetAddress)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"line1": "${updatedLine1}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/company/address/${addressId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.title` is equal to `${addressTitle}`
Then JSON element value from `${response}` by JSON path `$.line1` is equal to `${updatedLine1}`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/address/${addressId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`
