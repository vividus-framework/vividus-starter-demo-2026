Scenario: Verify PUT /api/company/address/{id}/ updates an address
Meta:
@api
@apiVersion 479
@endpoint PUT /api/company/address/{id}/
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
!-- Create an address to update
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "#{generate(regexify '[a-z]{10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `addressId`
!-- Update the address with PUT
Given I initialize scenario variable `updatedTitle` with value `#{generate(regexify '[a-z]{10}')}`
Given I initialize scenario variable `updatedLine1` with value `#{generate(Address.streetAddress)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "${updatedTitle}", "line1": "${updatedLine1}", "country": "US"}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/company/address/${addressId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.title` is equal to `${updatedTitle}`
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
