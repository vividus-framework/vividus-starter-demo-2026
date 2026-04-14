Meta:
@api
@apiVersion 479

Scenario: Verify GET /api/part/internal-price/ returns paginated list
Meta:
@endpoint GET /api/part/internal-price/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/internal-price/?limit=10`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.results` is greater than or equal to 0

Scenario: Verify GET /api/part/internal-price/{id}/ returns detail
Meta:
@endpoint GET /api/part/internal-price/{id}/
@responseCode 200
!-- Create a part for the internal price
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Create an internal price break
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "quantity": #{randomInt(1, 100)}, "price": "#{randomInt(1, 500)}.00", "price_currency": "USD"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/internal-price/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `priceId`
!-- Retrieve the internal price break
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/internal-price/${priceId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${priceId}`
Then JSON element value from `${response}` by JSON path `$.part` is equal to `${partId}`
!-- Cleanup: delete price break, deactivate and delete part
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/internal-price/${priceId}/`
Then response code is equal to `204`
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
