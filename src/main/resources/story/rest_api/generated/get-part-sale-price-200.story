Meta:
@api
@apiVersion 479

Scenario: Verify GET /api/part/sale-price/ returns paginated list
Meta:
@endpoint GET /api/part/sale-price/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/sale-price/?limit=10`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.results` is greater than or equal to 0

Scenario: Verify GET /api/part/sale-price/{id}/ returns detail
Meta:
@endpoint GET /api/part/sale-price/{id}/
@responseCode 200
!-- Create a salable part for the sale price
Given I initialize scenario variable `partName` with value `#{generate(regexify 'PART-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${partName}", "description": "#{generate(Lorem.sentence)}", "active": true, "salable": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `partId`
!-- Create a sale price break
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "quantity": #{randomInt(1, 100)}, "price": "#{randomInt(10, 500)}.00", "price_currency": "USD"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/sale-price/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `salePriceId`
!-- Retrieve the sale price break
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/sale-price/${salePriceId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${salePriceId}`
Then JSON element value from `${response}` by JSON path `$.part` is equal to `${partId}`
!-- Cleanup
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/sale-price/${salePriceId}/`
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
