Scenario: get server status
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}/api/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.server` is equal to `InvenTree`
Then JSON element value from `${response}` by JSON path `$.instance` is equal to `InvenTree Demo Server`
Then JSON element value from `${response}` by JSON path `$.apiVersion` is equal to `${apiVersion}`
