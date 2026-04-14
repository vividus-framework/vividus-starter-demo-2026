Meta:
@api
@apiVersion 479
@endpoint PUT /api/part/{id}/
@responseCode 200

Scenario: Verify PUT /api/part/{id}/ fully updates a part
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a part to update
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Update the part via PUT
Given I initialize scenario variable `updatedName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${updatedName}", "description": "${updatedDescription}", "active": true, "component": false, "purchaseable": true, "salable": false, "virtual": false}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/part/${partId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${partId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${updatedName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
Then JSON element value from `${response}` by JSON path `$.purchaseable` is equal to `true`
!-- Cleanup: deactivate and delete
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
