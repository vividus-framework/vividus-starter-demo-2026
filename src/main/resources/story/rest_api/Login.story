Scenario: get api access token
When I add request headers:
|name         |value                                           |
|Authorization|Basic #{encodeToBase64(${username}:${password})}|
When I execute HTTP GET request for resource with relative URL `/user/token/`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.token` to story variable `AccessToken`
