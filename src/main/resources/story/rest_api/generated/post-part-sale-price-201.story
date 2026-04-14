Meta:
@api
@apiVersion 479
@endpoint POST /api/part/sale-price/
@responseCode 201

Scenario: Verify POST /api/part/sale-price/ creates a sale price break
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a salable part
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
Given I initialize scenario variable `quantity` with value `#{randomInt(1, 100)}`
Given I initialize scenario variable `price` with value `#{randomInt(10, 500)}.00`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "quantity": ${quantity}, "price": "${price}", "price_currency": "USD"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/sale-price/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.part` is equal to `${partId}`
Then JSON element value from `${response}` by JSON path `$.price_currency` is equal to `USD`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `salePriceId`
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
