Scenario: Verify DELETE /api/company/contact/{id}/ deletes a single contact
Meta:
@api
@apiVersion 479
@endpoint DELETE /api/company/contact/{id}/
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
!-- Create a contact to delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "name": "#{generate(Name.fullName)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/contact/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `contactId`
!-- Delete the contact
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/contact/${contactId}/`
Then response code is equal to `204`
Then response does not contain body
!-- Cleanup company
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`

Scenario: Verify DELETE /api/company/contact/ bulk deletes contacts
Meta:
@api
@apiVersion 479
@endpoint DELETE /api/company/contact/
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
!-- Create a contact to bulk delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"company": ${companyId}, "name": "#{generate(Name.fullName)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/contact/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `contactId`
!-- Bulk delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"items": [${contactId}]}
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/contact/`
Then response code is equal to `204`
Then response does not contain body
!-- Cleanup company
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${companyId}/`
Then response code is equal to `204`
