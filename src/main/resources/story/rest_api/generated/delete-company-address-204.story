Scenario: Verify DELETE /api/company/address/{id}/ deletes a single address
Meta:
@api
@apiVersion 479
@endpoint DELETE /api/company/address/{id}/
@responseCode 204
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
!-- Create an address to delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "#{generate(regexify '[a-z]{10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `addressId`
!-- Delete the address
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/address/${addressId}/`
Then response code is equal to `204`
Then response does not contain body
!-- Cleanup company
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`

Scenario: Verify DELETE /api/company/address/ bulk deletes addresses
Meta:
@api
@apiVersion 479
@endpoint DELETE /api/company/address/
@responseCode 204
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
!-- Create an address to bulk delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "#{generate(regexify '[a-z]{10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `addressId`
!-- Bulk delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"items": [${addressId}]}
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `204`
Then response does not contain body
!-- Cleanup company
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`
