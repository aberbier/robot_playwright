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
Login With Valid Credentials
    [Documentation]    Navigates to the login page and logs in with valid credentials.
    Open Application
    Log In To Application    ${USERNAME}    ${PASSWORD}
    Fail
