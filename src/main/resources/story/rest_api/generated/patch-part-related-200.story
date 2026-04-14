Meta:
@api
@apiVersion 479
@endpoint PATCH /api/part/related/{id}/
@responseCode 200

Scenario: Verify PATCH /api/part/related/{id}/ partially updates a part relation
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create two parts
Given I initialize scenario variable `partName1` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName1}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId1`
Given I initialize scenario variable `partName2` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName2}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId2`
!-- Create a relation
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part_1": ${partId1}, "part_2": ${partId2}}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/related/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `relationId`
!-- Partially update the relation via PATCH
Given I initialize scenario variable `updatedNote` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"note": "${updatedNote}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/part/related/${relationId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${relationId}`
Then JSON element value from `${response}` by JSON path `$.note` is equal to `${updatedNote}`
!-- Cleanup
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/related/${relationId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"active": false}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/part/${partId1}/`
Then response code is equal to `200`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/${partId1}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"active": false}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/part/${partId2}/`
Then response code is equal to `200`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/${partId2}/`
Then response code is equal to `204`
