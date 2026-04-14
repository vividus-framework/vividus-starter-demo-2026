Meta:
@api
@apiVersion 479

Scenario: Verify GET /api/part/category/parameters/ returns paginated list
Meta:
@endpoint GET /api/part/category/parameters/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/category/parameters/?limit=10`
Then response code is equal to `200`
Then number of JSON elements from `${response}` by JSON path `$.results` is greater than or equal to 0

Scenario: Verify GET /api/part/category/parameters/{id}/ returns detail
Meta:
@endpoint GET /api/part/category/parameters/{id}/
@responseCode 200
!-- Create a category for the parameter template
Given I initialize scenario variable `categoryName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${categoryName}", "description": "#{generate(Lorem.sentence)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `categoryId`
!-- Fetch an existing parameter template to use
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/parameter/template/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `templateId`
!-- Create a category parameter template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"category": ${categoryId}, "template": ${templateId}, "default_value": "#{generate(regexify '[a-z0-9]{5}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/parameters/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `catParamId`
!-- Retrieve the created category parameter template
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/category/parameters/${catParamId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${catParamId}`
Then JSON element value from `${response}` by JSON path `$.category` is equal to `${categoryId}`
!-- Cleanup: delete category parameter template and category
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/category/parameters/${catParamId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/part/category/${categoryId}/`
Then response code is equal to `204`
