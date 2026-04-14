Scenario: Verify PATCH /api/company/{id}/ partially updates a company
Meta:
@api
@apiVersion 479
@endpoint PATCH /api/company/{id}/
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
!-- Partially update only the description
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"description": "${updatedDescription}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${companyName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`
