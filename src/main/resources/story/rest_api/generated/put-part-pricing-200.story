Meta:
@api
@apiVersion 479
@endpoint PUT /api/part/{id}/pricing/
@responseCode 200

Scenario: Verify PUT /api/part/{id}/pricing/ updates pricing overrides
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a part to update pricing for
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Update pricing overrides via PUT
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"override_min": "#{randomInt(1, 50)}.00", "override_min_currency": "USD", "override_max": "#{randomInt(51, 200)}.00", "override_max_currency": "USD"}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/part/${partId}/pricing/`
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
