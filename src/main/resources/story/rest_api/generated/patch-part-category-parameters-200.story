Meta:
@api
@apiVersion 479
@endpoint PATCH /api/part/category/parameters/{id}/
@responseCode 200

Scenario: Verify PATCH /api/part/category/parameters/{id}/ partially updates a category parameter template
When I save access token for user with username `${username}` and password `${password}` to story variable `token`
!-- Create a category
Given I initialize scenario variable `categoryName` with value `#{generate(regexify 'CAT-[a-z0-9]{8}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${categoryName}", "description": "#{generate(Lorem.sentence)}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `categoryId`
!-- Fetch an existing parameter template
When I add request headers:
|name         |value          |
|Authorization|Token ${token} |
When I execute HTTP GET request for resource with URL `${main-page-url}api/parameter/template/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `templateId`
!-- Create category parameter template
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"category": ${categoryId}, "template": ${templateId}, "default_value": "#{generate(regexify '[a-z0-9]{5}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/part/category/parameters/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `catParamId`
!-- Partially update via PATCH
Given I initialize scenario variable `patchedDefault` with value `#{generate(regexify '[a-z0-9]{5}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"default_value": "${patchedDefault}"}
When I execute HTTP PATCH request for resource with URL `${main-page-url}api/part/category/parameters/${catParamId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.pk` is equal to `${catParamId}`
Then JSON element value from `${response}` by JSON path `$.default_value` is equal to `${patchedDefault}`
!-- Cleanup
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
