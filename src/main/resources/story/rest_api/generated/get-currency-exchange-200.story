Scenario: Verify GET /api/currency/exchange/ returns currency exchange information
Meta:
@api
@apiVersion 479
@endpoint GET /api/currency/exchange/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/currency/exchange/`
Then response code is equal to `200`
!-- Default base currency is USD per INVENTREE_DEFAULT_CURRENCY setting
Then JSON element value from `${response}` by JSON path `$.base_currency` is equal to `USD`
Then number of JSON elements from `${response}` by JSON path `$.exchange_rates` is equal to 1
