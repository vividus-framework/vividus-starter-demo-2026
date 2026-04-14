Meta:
@api
@apiVersion 479
@endpoint POST /api/part/category/
@responseCode 201

Scenario: Verify POST /api/part/category/ creates a new category
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
Given I initialize scenario variable `categoryName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
Given I initialize scenario variable `categoryDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${categoryName}", "description": "${categoryDescription}", "structural": false}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/`
Then response code is equal to `201`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${categoryName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${categoryDescription}`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `categoryId`
!-- Cleanup: delete the created category
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `204`
