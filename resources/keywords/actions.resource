*** Settings ***
Resource   ../locators/locators.resource

*** Keywords ***
Open Application Home Page
    Navigate To Home Page

Enter Username
    [Arguments]    ${username}
    Click    ${LOGIN.username_field}
    Fill Text    ${LOGIN.username_field}    ${username}

Enter Password
    [Arguments]    ${password}
    Click    ${LOGIN.password_field}
    Fill Text    ${LOGIN.password_field}    ${password}

Click Login Button
    Click    ${LOGIN.login_btn}
