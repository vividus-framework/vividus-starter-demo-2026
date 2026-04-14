Meta:
@api
@apiVersion 479
@endpoint POST /api/parameter/template/
@responseCode 201

Scenario: Verify POST /api/parameter/template/ creates a new parameter template
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
Given I initialize scenario variable `templateName` with value `#{generate(regexify '[A-Z][a-z]{5,10}')}`
Given I initialize scenario variable `templateUnits` with value `#{anyOf(mm, kg, pcs, V, A, Ohm)}`
Given I initialize scenario variable `templateDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "${templateName}", "units": "${templateUnits}", "description": "${templateDescription}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/template/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${templateName}`
Then JSON element value from `${response}` by JSON path `$.units` is equal to `${templateUnits}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${templateDescription}`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Cleanup: delete the created template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `204`
