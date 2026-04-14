Meta:
@api
@apiVersion 479
@endpoint DELETE /api/part/category/{id}/
@responseCode 204

Scenario: Verify DELETE /api/part/category/{id}/ deletes a category
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a category to delete
Given I initialize scenario variable `categoryName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${categoryName}", "description": "#{generate(Lorem.sentence)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `categoryId`
!-- Delete the category
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `204`
