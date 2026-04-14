Meta:
@api
@apiVersion 479

Scenario: Verify GET /api/part/category/ returns paginated list of categories
Meta:
@endpoint GET /api/part/category/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/category/?limit=10`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.results` is greater than 0
Then JSON element value from `${response}` by JSON path `$.count` is greater than `0`

Scenario: Verify GET /api/part/category/{id}/ returns category details
Meta:
@endpoint GET /api/part/category/{id}/
@responseCode 200
!-- Create a category to retrieve
Given I initialize scenario variable `categoryName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${categoryName}", "description": "#{generate(Lorem.sentence)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `categoryId`
!-- Retrieve the created category
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${categoryId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${categoryName}`
!-- Cleanup: delete the category
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `204`
