Scenario: Verify DELETE /api/parameter/template/{id}/ deletes a parameter template
Meta:
@api
@apiVersion 479
@endpoint DELETE /api/parameter/template/{id}/
@responseCode 204
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create prerequisite template to delete
Given I initialize scenario variable `templateName` with value `#{generate(regexify '[a-z]{10}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${templateName}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Delete the template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/parameter/template/${templateId}/`
Then response code is equal to `204`
Then response does not contain body
