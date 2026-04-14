Meta:
@api
@apiVersion 479
@endpoint PATCH /api/part/{id}/
@responseCode 200

Scenario: Verify PATCH /api/part/{id}/ partially updates a part
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a part to partially update
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Partially update the part via PATCH
Given I initialize scenario variable `patchedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"description": "${patchedDescription}", "purchaseable": true}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/part/${partId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${partId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${partName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${patchedDescription}`
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
