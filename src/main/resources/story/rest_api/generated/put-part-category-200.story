Meta:
@api
@apiVersion 479
@endpoint PUT /api/part/category/{id}/
@responseCode 200

Scenario: Verify PUT /api/part/category/{id}/ fully updates a category
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a category to update
Given I initialize scenario variable `categoryName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${categoryName}", "description": "#{generate(Lorem.sentence)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `categoryId`
!-- Update category via PUT
Given I initialize scenario variable `updatedName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${updatedName}", "description": "${updatedDescription}", "structural": false}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${categoryId}`
Then JSON element value from `${response}` by JSON path `$.name` is equal to `${updatedName}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
!-- Cleanup: delete the category
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `204`
