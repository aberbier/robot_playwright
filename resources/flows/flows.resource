*** Settings ***
Resource    ../keywords/actions.resource
# High level keywords - these are test steps - they are made of actions keywords.
# They should be reusable across test cases and test suites.
# They should not contain assertions, but rather return values that can be asserted in the test case.

*** Keywords ***
Open Application
    Open Application Home Page

Log In To Application
    [Arguments]    ${username}    ${password}
    Enter Username    ${username}
    Enter Password    ${password}
    Click Login Button

Navigate Wikipedia To Random Article
    Open Wikipedia Home Page
    Verify Anniversary Banner Text
    Click Encyclopedia Hero Text
    Click Encyclopedia Hero Text
    Click English Articles Link
    Open Main Menu
    Click Random Article Link

Navigate IKEA To Products
    Open IKEA Home Page
    Click Stories Link
    Dismiss Cookies
    Dismiss Cookies
    Click Our Business Link
    Click Go Shopping Link
    Verify Products Button Is Visible
