Scenario: Verify POST /api/company/ creates a new company
Meta:
@api
@apiVersion 479
@endpoint POST /api/company/
@responseCode 201
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
Given I initialize scenario variable `companyName` with value `#{generate(Company.name)} #{generate(regexify '[a-z]{5}')}`
Given I initialize scenario variable `companyDescription` with value `#{generate(Lorem.sentence)}`
Given I initialize scenario variable `companyCurrency` with value `#{anyOf(USD, EUR, GBP, CAD, AUD)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${companyName}", "description": "${companyDescription}", "currency": "${companyCurrency}", "is_supplier": true, "is_manufacturer": false, "is_customer": false}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${companyName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${companyDescription}`
Then JSON element value from `${response}` by JSON path `$.currency` is equal to `${companyCurrency}`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `companyId`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`
