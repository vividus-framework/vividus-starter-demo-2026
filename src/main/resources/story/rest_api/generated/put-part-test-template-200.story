Meta:
@api
@apiVersion 479
@endpoint PUT /api/part/test-template/{id}/
@responseCode 200

Scenario: Verify PUT /api/part/test-template/{id}/ updates a test template
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
!-- Create a test template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "test_name": "#{generate(regexify 'TEST-[a-z0-9]{8}')}", "description": "#{generate(Lorem.sentence)}", "required": false}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/test-template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Update via PUT
Given I initialize scenario variable `updatedTestName` with value `#{generate(regexify 'TEST-[a-z0-9]{8}')}`
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "test_name": "${updatedTestName}", "description": "${updatedDescription}", "required": true, "requires_value": true, "requires_attachment": false, "enabled": true}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/part/test-template/${templateId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${templateId}`
Then JSON element value from `${response}` by JSON path `$.test_name` is equal to `${updatedTestName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
Then JSON element value from `${response}` by JSON path `$.required` is equal to `true`
!-- Cleanup
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/test-template/${templateId}/`
Then response code is equal to `204`
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
