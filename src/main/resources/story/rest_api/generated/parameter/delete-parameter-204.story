Meta:
@api
@apiVersion 479
@endpoint DELETE /api/parameter/{id}/
@responseCode 204

Scenario: Verify DELETE /api/parameter/{id}/ deletes a parameter
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
!-- Create a parameter to delete
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"template": ${templateId}, "model_type": "part.part", "model_id": ${partId}, "data": "#{generate(regexify '[0-9]{1,5}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `paramId`
!-- Delete the parameter
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/${paramId}/`
Then response code is equal to `204`
Then response does not contain body
!-- Verify the parameter no longer exists
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}/api/parameter/${paramId}/`
Then response code is equal to `404`
!-- Cleanup: delete the template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId}/`
Then response code is equal to `204`

Scenario: Verify DELETE /api/parameter/ bulk deletes parameters
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Get an existing part ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}/api/part/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `partId`
!-- Create first parameter template
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "#{generate(regexify '[A-Z][a-z]{5,10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId1`
!-- Create second parameter template
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"name": "#{generate(regexify '[A-Z][a-z]{5,10}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/template/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `templateId2`
!-- Create first parameter
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"template": ${templateId1}, "model_type": "part.part", "model_id": ${partId}, "data": "#{generate(regexify '[0-9]{1,5}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `paramId1`
!-- Create second parameter
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"template": ${templateId2}, "model_type": "part.part", "model_id": ${partId}, "data": "#{generate(regexify '[0-9]{1,5}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}/api/parameter/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `paramId2`
!-- Bulk delete the parameters
When I add request headers:
|name         |value            |
|Authorization|Token ${token}   |
|Content-Type |application/json |
Given request body: {"items": [${paramId1}, ${paramId2}]}
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/`
Then response code is equal to `204`
!-- Cleanup: delete the templates
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId1}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}/api/parameter/template/${templateId2}/`
Then response code is equal to `204`
