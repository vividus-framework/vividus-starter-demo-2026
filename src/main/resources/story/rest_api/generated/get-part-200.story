Meta:
@api
@apiVersion 479

Scenario: Verify GET /api/part/ returns paginated list of parts
Meta:
@endpoint GET /api/part/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/?limit=10`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.results` is greater than 0
Then JSON element value from `${response}` by JSON path `$.count` is greater than `0`

Scenario: Verify GET /api/part/{id}/ returns part details
Meta:
@endpoint GET /api/part/{id}/
@responseCode 200
!-- Create a part to retrieve
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Retrieve the created part
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/${partId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${partId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${partName}`
Then JSON element value from `${response}` by JSON path `$.active` is equal to `true`
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
