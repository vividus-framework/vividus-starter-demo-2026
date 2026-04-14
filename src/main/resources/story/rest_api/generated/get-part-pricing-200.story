Meta:
@api
@apiVersion 479
@endpoint GET /api/part/{id}/pricing/
@responseCode 200

Scenario: Verify GET /api/part/{id}/pricing/ returns pricing data
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a part to get pricing for
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Get pricing information
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/${partId}/pricing/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.currency` is equal to `USD`
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
