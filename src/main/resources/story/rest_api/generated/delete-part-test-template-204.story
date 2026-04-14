Meta:
@api
@apiVersion 479
@endpoint DELETE /api/part/test-template/{id}/
@responseCode 204

Scenario: Verify DELETE /api/part/test-template/{id}/ deletes a test template
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a testable part
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true, "testable": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Create a test template to delete
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "test_name": "#{generate(regexify 'TEST-[a-z0-9]{8}')}", "description": "#{generate(Lorem.sentence)}", "required": false}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/test-template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Delete the test template
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/test-template/${templateId}/`
Then response code is equal to `204`
!-- Cleanup: deactivate and delete the part
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"active": false}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/part/${partId}/`
Then response code is equal to `200`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/${partId}/`
Then response code is equal to `204`
