Meta:
@api
@apiVersion 479
@endpoint GET /api/part/category/tree/
@responseCode 200

Scenario: Verify GET /api/part/category/tree/ returns category tree
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/category/tree/?limit=10`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.results` is greater than 0
