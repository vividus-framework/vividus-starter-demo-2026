Meta:
@api
@apiVersion 479
@endpoint PATCH /api/parameter/template/{id}/
@responseCode 200

Scenario: Verify PATCH /api/parameter/template/{id}/ partially updates a parameter template
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create a parameter template to partially update
Given I initialize scenario variable `originalName` with value `#{generate(regexify '[A-Z][a-z]{5,10}')}`
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "${originalName}", "description": "#{generate(Lorem.sentence)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Perform partial update via PATCH (only update description)
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"description": "${updatedDescription}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${templateId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${originalName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
!-- Cleanup: delete the template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `204`
