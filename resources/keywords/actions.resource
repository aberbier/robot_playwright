*** Settings ***
Resource   ../locators/locators.resource
# Low level atomic keywords that perform actions on locators

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

Open Wikipedia Home Page
    Go To    https://www.wikipedia.org/

Verify Anniversary Banner Text
    Get Text    ${WIKIPEDIA_HOME.anniversary_banner}    contains    Unlock birthday surprises on Wikipedia

Click Encyclopedia Hero Text
    Click    ${WIKIPEDIA_HOME.encyclopedia_hero_text}

Click English Articles Link
    Click    ${WIKIPEDIA_HOME.english_articles_link}

Open Main Menu
    Click    ${WIKIPEDIA_EN.main_menu_btn}

Click Random Article Link
    Click    ${WIKIPEDIA_EN.random_article_link}

Verify Search Button Is Visible
    Get Element States    ${WIKIPEDIA_EN.search_btn}    contains    visible

Open IKEA Home Page
    Go To    https://www.ikea.com/

Click Stories Link
    Click    ${IKEA_HOME.stories_link}

Dismiss Cookies
    Click    ${IKEA_HOME.cookie_banner}

Click Our Business Link
    Click    ${IKEA_HOME.our_business_link}

Click Go Shopping Link
    Click    ${IKEA_HOME.go_shopping_link}

Verify Products Button Is Visible
    Get Element States    ${IKEA_HOME.products_button}    contains    visible
