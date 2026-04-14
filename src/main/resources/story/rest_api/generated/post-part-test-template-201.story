Meta:
@api
@apiVersion 479
@endpoint POST /api/part/test-template/
@responseCode 201

Scenario: Verify POST /api/part/test-template/ creates a test template
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
Given I initialize scenario variable `testName` with value `#{generate(regexify 'TEST-[a-z0-9]{8}')}`
Given I initialize scenario variable `testDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "test_name": "${testName}", "description": "${testDescription}", "required": true, "requires_value": true, "requires_attachment": false, "enabled": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/test-template/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.test_name` is equal to `${testName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${testDescription}`
Then JSON element value from `${response}` by JSON path `$.required` is equal to `true`
Then JSON element value from `${response}` by JSON path `$.requires_value` is equal to `true`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
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
