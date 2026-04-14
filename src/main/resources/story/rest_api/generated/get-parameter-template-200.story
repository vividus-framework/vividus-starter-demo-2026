Scenario: Verify GET /api/parameter/template/ returns paginated list of parameter templates
Meta:
@api
@apiVersion 479
@endpoint GET /api/parameter/template/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/parameter/template/?limit=10`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.count` is greater than or equal to `0`

Scenario: Verify GET /api/parameter/template/{id}/ returns a single parameter template
Meta:
@api
@apiVersion 479
@endpoint GET /api/parameter/template/{id}/
@responseCode 200
!-- Create a parameter template to ensure we have a known resource to retrieve
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
Given I initialize scenario variable `templateName` with value `#{generate(regexify '[a-z]{10}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${templateName}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Retrieve the created template by ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/parameter/template/${templateId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${templateId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${templateName}`
!-- Cleanup: delete the created template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/parameter/template/${templateId}/`
Then response code is equal to `204`
