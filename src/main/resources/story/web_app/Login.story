Scenario: login to web
Given I am on main application page
When I enter `${username}` in field located by `fieldName(username)`
When I enter `${password}` in field located by `fieldName(password)`
When I click on element located by `caseInsensitiveText(Log In)`
When I wait until element located by `caseInsensitiveText(Logged in successfully)` appears
