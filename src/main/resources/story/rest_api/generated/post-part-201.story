Meta:
@api
@apiVersion 479
@endpoint POST /api/part/
@responseCode 201

Scenario: Verify POST /api/part/ creates a new part
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
Given I initialize scenario variable `partDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "${partDescription}", "active": true, "component": true, "purchaseable": false, "salable": false, "virtual": false}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${partName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${partDescription}`
Then JSON element value from `${response}` by JSON path `$.active` is equal to `true`
Then JSON element value from `${response}` by JSON path `$.component` is equal to `true`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Cleanup: deactivate and delete the created part
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
