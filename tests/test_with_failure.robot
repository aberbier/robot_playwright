*** Settings ***
Resource          ../resources/common_resource.robot
Resource          ../resources/flows/flows.resource

Suite Setup       Setup Global Browser
Suite Teardown    Teardown Global Browser
Test Setup        Start UI Test
Test Teardown     Finish UI Test

*** Variables ***
${USERNAME}    practice
${PASSWORD}    SuperSecretPassword!

*** Test Cases ***
Login With Valid Credentials 2
    [Documentation]    Navigates to the login page and logs in with valid credentials.
    Open Application
    Log In To Application    ${USERNAME}    wrong_password

Test That Fails Intentionally
    [Documentation]    This test intentionally fails to demonstrate error reporting.
    Open Application
    Click    internal:role=button[name="NonExistentButton"i]
