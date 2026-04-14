Scenario: Verify POST /api/currency/refresh/ triggers exchange rate update
Meta:
@api
@apiVersion 479
@endpoint POST /api/currency/refresh/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
When I execute HTTP POST request for resource with URL `${main-page-url}api/currency/refresh/`
Then response code is equal to `200`
