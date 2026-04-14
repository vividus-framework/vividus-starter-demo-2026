Meta:
@api
@apiVersion 479
@endpoint PUT /api/parameter/template/{id}/
@responseCode 200

Scenario: Verify PUT /api/parameter/template/{id}/ fully updates a parameter template
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create a parameter template to update
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "#{generate(regexify '[A-Z][a-z]{5,10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Perform full update via PUT
Given I initialize scenario variable `updatedName` with value `#{generate(regexify '[A-Z][a-z]{5,10}')}`
Given I initialize scenario variable `updatedUnits` with value `#{anyOf(cm, lb, units, W, mA)}`
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "${updatedName}", "units": "${updatedUnits}", "description": "${updatedDescription}"}
When I execute HTTP PUT request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${templateId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${updatedName}`
Then JSON element value from `${response}` by JSON path `$.units` is equal to `${updatedUnits}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
!-- Cleanup: delete the template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `204`
