Scenario: Verify POST /api/company/contact/ creates a new contact
Meta:
@api
@apiVersion 479
@endpoint POST /api/company/contact/
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
!-- Create a contact
Given I initialize scenario variable `contactName` with value `#{generate(Name.fullName)}`
Given I initialize scenario variable `contactEmail` with value `#{generate(Internet.emailAddress)}`
Given I initialize scenario variable `contactRole` with value `#{anyOf(Sales, Engineering, Support, Management)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "name": "${contactName}", "email": "${contactEmail}", "role": "${contactRole}", "phone": "#{generate(numerify '+1-###-###-####')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/contact/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${contactName}`
Then JSON element value from `${response}` by JSON path `$.email` is equal to `${contactEmail}`
Then JSON element value from `${response}` by JSON path `$.role` is equal to `${contactRole}`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `contactId`
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
