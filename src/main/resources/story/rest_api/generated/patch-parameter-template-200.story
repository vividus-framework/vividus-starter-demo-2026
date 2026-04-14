Scenario: Verify PATCH /api/parameter/template/{id}/ partially updates a parameter template
Meta:
@api
@apiVersion 479
@endpoint PATCH /api/parameter/template/{id}/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create prerequisite template
Given I initialize scenario variable `templateName` with value `#{generate(regexify '[a-z]{10}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${templateName}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Partially update only the description
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"description": "${updatedDescription}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/parameter/template/${templateId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${templateName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/parameter/template/${templateId}/`
Then response code is equal to `204`
