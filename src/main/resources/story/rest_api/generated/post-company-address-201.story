Scenario: Verify POST /api/company/address/ creates a new address
Meta:
@api
@apiVersion 479
@endpoint POST /api/company/address/
@responseCode 201
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
!-- Create an address
Given I initialize scenario variable `addressTitle` with value `#{generate(regexify '[a-z]{10}')}`
Given I initialize scenario variable `addressLine1` with value `#{generate(Address.streetAddress)}`
Given I initialize scenario variable `postalCode` with value `#{generate(numerify '#####')}`
Given I initialize scenario variable `country` with value `#{anyOf(US, GB, DE, FR, CA)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "title": "${addressTitle}", "line1": "${addressLine1}", "postal_code": "${postalCode}", "country": "${country}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/address/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.title` is equal to `${addressTitle}`
Then JSON element value from `${response}` by JSON path `$.line1` is equal to `${addressLine1}`
Then JSON element value from `${response}` by JSON path `$.country` is equal to `${country}`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `addressId`
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
