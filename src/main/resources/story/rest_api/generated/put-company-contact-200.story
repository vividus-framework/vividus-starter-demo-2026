Scenario: Verify PUT /api/company/contact/{id}/ updates a contact
Meta:
@api
@apiVersion 479
@endpoint PUT /api/company/contact/{id}/
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
!-- Create a contact to update
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "name": "#{generate(Name.fullName)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/contact/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `contactId`
!-- Update the contact with PUT
Given I initialize scenario variable `updatedName` with value `#{generate(Name.fullName)}`
Given I initialize scenario variable `updatedEmail` with value `#{generate(Internet.emailAddress)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "name": "${updatedName}", "email": "${updatedEmail}", "role": "#{anyOf(Sales, Engineering, Support)}"}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/company/contact/${contactId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${updatedName}`
Then JSON element value from `${response}` by JSON path `$.email` is equal to `${updatedEmail}`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/contact/${contactId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`
