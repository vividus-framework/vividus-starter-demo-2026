Scenario: Verify GET /api/company/address/ returns paginated list of addresses
Meta:
@api
@apiVersion 479
@endpoint GET /api/company/address/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/company/address/?limit=10`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.count` is greater than or equal to `0`

Scenario: Verify GET /api/company/address/{id}/ returns a single address
Meta:
@api
@apiVersion 479
@endpoint GET /api/company/address/{id}/
@responseCode 200
!-- Create a company and address to ensure we have a known resource
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
Given I initialize scenario variable `companyName` with value `#{generate(Company.name)} #{generate(regexify '[a-z]{5}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${companyName}", "currency": "USD", "is_supplier": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `companyId`
!-- Create an address for the company
Given I initialize scenario variable `addressTitle` with value `#{generate(regexify '[a-z]{10}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "${addressTitle}", "line1": "#{generate(Address.streetAddress)}", "postal_code": "#{generate(numerify '#####')}", "country": "#{anyOf(US, GB, DE, FR, CA)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `addressId`
!-- Retrieve the address by ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/company/address/${addressId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${addressId}`
Then JSON element value from `${response}` by JSON path `$.title` is equal to `${addressTitle}`
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
