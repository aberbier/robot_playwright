*** Settings ***
Resource          ../resources/common_resource.robot
Resource          ../resources/flows/flows.resource

Suite Setup       Setup Global Browser
Suite Teardown    Teardown Global Browser
Test Setup        Start UI Test
Test Teardown     Finish UI Test

*** Test Cases ***
Ikea Testing
    [Documentation]    Navigates through IKEA site links and verifies Products button is visible.
    Navigate IKEA To Products
