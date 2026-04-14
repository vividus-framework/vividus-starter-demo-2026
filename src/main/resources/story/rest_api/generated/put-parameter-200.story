Scenario: Verify PUT /api/parameter/{id}/ updates a parameter
Meta:
@api
@apiVersion 479
@endpoint PUT /api/parameter/{id}/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create a parameter template as prerequisite
Given I initialize scenario variable `templateName` with value `#{generate(regexify '[a-z]{10}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${templateName}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Get a valid part ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `partId`
!-- Create a parameter to update
Given I initialize scenario variable `paramData` with value `#{generate(regexify '[0-9]{1,5}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"template": ${templateId}, "model_type": "part.part", "model_id": ${partId}, "data": "${paramData}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/parameter/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `parameterId`
!-- Update the parameter with PUT
Given I initialize scenario variable `updatedData` with value `#{generate(regexify '[0-9]{1,5}')}`
Given I initialize scenario variable `updatedNote` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"template": ${templateId}, "model_type": "part.part", "model_id": ${partId}, "data": "${updatedData}", "note": "${updatedNote}"}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/parameter/${parameterId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.data` is equal to `${updatedData}`
Then JSON element value from `${response}` by JSON path `$.note` is equal to `${updatedNote}`
!-- Cleanup: delete parameter and template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/parameter/${parameterId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/parameter/template/${templateId}/`
Then response code is equal to `204`
