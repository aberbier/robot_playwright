*** Settings ***
Resource    ../keywords/actions.resource

*** Keywords ***
Open Application
    Open Application Home Page

Log In To Application
    [Arguments]    ${username}    ${password}
    Enter Username    ${username}
    Enter Password    ${password}
    Click Login Button
