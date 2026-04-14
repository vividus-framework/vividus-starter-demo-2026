Meta:
@api
@apiVersion 479
@endpoint PATCH /api/parameter/{id}/
@responseCode 200

Scenario: Verify PATCH /api/parameter/{id}/ partially updates a parameter
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Get an existing part ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}/api/part/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `partId`
!-- Create a parameter template
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "#{generate(regexify '[A-Z][a-z]{5,10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId`
!-- Create a parameter
Given I initialize scenario variable `originalData` with value `#{generate(regexify '[0-9]{1,5}')}`
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"template": ${templateId}, "model_type": "part.part", "model_id": ${partId}, "data": "${originalData}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `paramId`
!-- Perform partial update via PATCH (only update data)
Given I initialize scenario variable `updatedData` with value `#{generate(regexify '[0-9]{1,5}')}`
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"data": "${updatedData}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}/api/parameter/${paramId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${paramId}`
Then JSON element value from `${response}` by JSON path `$.data` is equal to `${updatedData}`
Then JSON element value from `${response}` by JSON path `$.template` is equal to `${templateId}`
!-- Cleanup: delete parameter and template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/${paramId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `204`
