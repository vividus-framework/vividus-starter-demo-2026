Scenario: Verify PUT /api/company/part/manufacturer/{id}/ updates a manufacturer part
Meta:
@api
@apiVersion 479
@endpoint PUT /api/company/part/manufacturer/{id}/
@responseCode 200
When I save access token for user with username `${username}` and password `${password}` to scenario variable `token`
!-- Create prerequisite manufacturer company
Given I initialize scenario variable `companyName` with value `#{generate(Company.name)} #{generate(regexify '[a-z]{5}')}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"name": "${companyName}", "currency": "USD", "is_manufacturer": true}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `manufacturerId`
!-- Get a valid part ID
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP GET request for resource with URL `${main-page-url}api/part/?limit=1`
Then response code is equal to `200`
When I save JSON element value from `${response}` by JSON path `$.results[0].pk` to scenario variable `partId`
!-- Create a manufacturer part to update
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "manufacturer": ${manufacturerId}, "MPN": "#{generate(regexify '[A-Z]{2}[0-9]{6}')}"}
When I execute HTTP POST request for resource with URL `${main-page-url}api/company/part/manufacturer/`
Then response code is equal to `201`
When I save JSON element value from `${response}` by JSON path `$.pk` to scenario variable `mfgPartId`
!-- Update with PUT
Given I initialize scenario variable `updatedMpn` with value `#{generate(regexify '[A-Z]{2}[0-9]{6}')}`
Given I initialize scenario variable `updatedDescription` with value `#{generate(Lorem.sentence)}`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
|Content-Type |application/json|
Given request body: {"part": ${partId}, "manufacturer": ${manufacturerId}, "MPN": "${updatedMpn}", "description": "${updatedDescription}"}
When I execute HTTP PUT request for resource with URL `${main-page-url}api/company/part/manufacturer/${mfgPartId}/`
Then response code is equal to `200`
Then JSON element value from `${response}` by JSON path `$.MPN` is equal to `${updatedMpn}`
Then JSON element value from `${response}` by JSON path `$.description` is equal to `${updatedDescription}`
!-- Cleanup
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/part/manufacturer/${mfgPartId}/`
Then response code is equal to `204`
When I add request headers:
|name         |value           |
|Authorization|Token ${token}  |
When I execute HTTP DELETE request for resource with URL `${main-page-url}api/company/${manufacturerId}/`
Then response code is equal to `204`
