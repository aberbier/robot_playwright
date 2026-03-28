*** Settings ***
Library    Browser         auto_closing_level=MANUAL    tracing_group_mode=Browser
Library    String
Library    OperatingSystem

*** Variables ***
${URL_BASE}         https://practice.expandtesting.com/login
${BROWSER}          chromium
${HEADLESS}         True
${ENABLE_TRACE}     False
${TRACE_DIR}        ${OUTPUT DIR}/traces
@{POPUP_HANDLERS}
...                 test       automation

*** Keywords ***
Setup Global Browser
    [Documentation]    Launched once per Suite (Pabot Worker) to minimize process overhead.
    New Browser    ${BROWSER}    headless=${HEADLESS}

Teardown Global Browser
    [Documentation]    Terminates the browser process after the Suite completion.
    Close Browser

Start UI Test
    [Documentation]    Initializes a fresh browser context. Tracing is optional and disabled by default.
    ${trace_enabled}=    Convert To Boolean    ${ENABLE_TRACE}
    IF  ${trace_enabled}
        ${safe_suite}=    Convert To Lower Case    ${SUITE NAME}
        ${safe_suite}=    Replace String Using Regexp    ${safe_suite}    [^a-z0-9]+    _
        ${safe_suite}=    Strip String    ${safe_suite}    characters=_
        ${safe_suite}=    Set Variable If    '${safe_suite}' == ''    suite    ${safe_suite}
        ${safe_name}=    Convert To Lower Case    ${TEST_NAME}
        ${safe_name}=    Replace String Using Regexp    ${safe_name}    [^a-z0-9]+    _
        ${safe_name}=    Strip String    ${safe_name}    characters=_
        ${safe_name}=    Set Variable If    '${safe_name}' == ''    test_case    ${safe_name}
        ${trace_zip}=    Set Variable    ${safe_suite}__${safe_name}.zip
        ${trace_dir_exists}=    Run Keyword And Return Status    Directory Should Exist    ${TRACE_DIR}
        IF  not ${trace_dir_exists}
            Create Directory    ${TRACE_DIR}
        END
        Set Test Variable    ${CURRENT_TRACE_PATH}    ${TRACE_DIR}/${trace_zip}
        ${trace_exists}=    Run Keyword And Return Status    File Should Exist    ${CURRENT_TRACE_PATH}
        IF    ${trace_exists}
            Remove File    ${CURRENT_TRACE_PATH}
        END
        New Context    tracing=traces/${trace_zip}
    ELSE
        Set Test Variable    ${CURRENT_TRACE_PATH}    ${NONE}
        New Context    tracing=${False}
    END

    New Page

Finish UI Test
    [Documentation]    Closes the context. If trace is enabled, Browser library writes trace zip on close.
    Close Context

Navigate To Home Page
    [Documentation]    Navigates to the application home page.
    Go To    ${URL_BASE}
