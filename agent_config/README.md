# Automation Framework: Scalable Robot Framework & Playwright Blueprint

This document specifies the architectural standards for a high-volume UI automation framework. The design utilizes Robot Framework, the Browser library (Playwright), and Pabot to achieve parallel execution, strict isolation, and maintainable locator strategies.

---

## Project Directory Structure

The framework is organized into distinct layers to separate infrastructure, data, atomic actions, and business logic.

```text
project-root/
│
├── tests/                          # Test Execution: High-level test suites
│   └── sample_test_suite.robot
│
├── resources/
│   ├── common_resource.robot       # Infrastructure: Global lifecycle and tracing
│   │
│   ├── locators/                   # Data: UI element dictionaries
│   │   └── locators.resource
│   │
│   ├── keywords/                   # Actions: Atomic page-level keywords
│   │   └── actions.resource
│   │
│   └── flows/                      # Logic: Multi-step functional flows
│       └── flows.resource
└── output/                        # Output: Logs, reports, and traces
```

---

## 1. Global Lifecycle & Configuration
This file manages the browser process and context isolation. It is configured to optimize performance by launching the browser per suite and isolating tests via individual contexts.

```robotframework
# File: project-root/resources/common_resource.robot

*** Settings ***
Library    Browser
Library    String
Library    OperatingSystem

*** Variables ***
${URL_BASE}         https://example-ecommerce.test/
${BROWSER}          chromium
${HEADLESS}         True
${ENABLE_TRACE}     False
${TRACE_DIR}        ${OUTPUT DIR}/traces

*** Keywords ***
Setup Global Browser
    [Documentation]    Launched once per Suite (Pabot Worker) to minimize process overhead.
    New Browser    ${BROWSER}    headless=${HEADLESS}

Teardown Global Browser
    [Documentation]    Terminates the browser process after the Suite completion.
    Close Browser

Start UI Test
    [Documentation]    Initializes a fresh browser context. Tracing is optional and disabled by default.
    IF    '${ENABLE_TRACE}' == 'True'
        ${safe_name}=    Convert To Lower Case    ${TEST_NAME}
        ${safe_name}=    Replace String Using Regexp    ${safe_name}    [^a-z0-9]+    _
        ${safe_name}=    Strip String    ${safe_name}    characters=_
        ${safe_name}=    Set Variable If    '${safe_name}' == ''    test_case    ${safe_name}
        ${trace_dir_exists}=    Run Keyword And Return Status    Directory Should Exist    ${TRACE_DIR}
        IF    not ${trace_dir_exists}
            Create Directory    ${TRACE_DIR}
        END
        Set Test Variable    ${CURRENT_TRACE_PATH}    ${TRACE_DIR}/${safe_name}.zip
        ${trace_exists}=    Run Keyword And Return Status    File Should Exist    ${CURRENT_TRACE_PATH}
        IF    ${trace_exists}
            Remove File    ${CURRENT_TRACE_PATH}
        END
        New Context    tracing=${CURRENT_TRACE_PATH}
    ELSE
        Set Test Variable    ${CURRENT_TRACE_PATH}    ${NONE}
        New Context
    END

    New Page

Finish UI Test
    [Documentation]    Closes the context. If trace is enabled, Browser library writes trace zip on close.
    Close Context

Navigate To Home Page
    Go To    ${URL_BASE}
```

---

## 2. Locator Layer (Dictionaries)
UI elements are stored in dictionaries to provide namespacing, preventing variable collisions and centralizing maintenance.

```robotframework
# File: project-root/resources/locators/locators.resource

*** Variables ***
&{NAV}
...    search_input=internal:role=searchbox[name="Search"i]
...    search_btn=internal:role=button[name="Go"s]

&{SEARCH_RESULTS}
...    first_item_link=internal:role=link[name="Item"i]

&{PRODUCT_PAGE}
...    format_option=internal:role=radio[name="Format"i]
...    preview_btn=internal:role=button[name="Preview"i]
...    price_label=internal:role=heading[name="Price"i]

&{PREVIEW_IFRAME}
...    next_page=id=preview-frame >>> internal:role=button[name="Next page"i]
...    close_btn=id=preview-frame >>> internal:role=button[name="Close"i]
```

---

## 3. Page Actions Layer (Atomic Keywords)
These keywords perform discrete UI interactions. They reside in page-specific files and rely on the locator layer for element definitions.

```robotframework
# File: project-root/resources/keywords/actions.resource

*** Settings ***
Library    Browser
Resource   ../locators/locators.resource

*** Keywords ***
Submit Search For Term
    [Arguments]    ${term}
    Fill Text      ${NAV.search_input}    ${term}
    Click          ${NAV.search_btn}

Select First Item From Results
    Click          ${SEARCH_RESULTS.first_item_link}

Open Item Preview
    Click          ${PRODUCT_PAGE.format_option}
    Click          ${PRODUCT_PAGE.preview_btn}

Close Preview
    Click          ${PREVIEW_IFRAME.close_btn}

Verify Price Is Correct
    [Arguments]    ${expected_price}
    Get Text       ${PRODUCT_PAGE.price_label}    contains    ${expected_price}
```

---

## 4. Functional Flow Layer (Business Logic)

This layer aggregates atomic keywords into functional sequences. No direct locator references are permitted in this layer.

```robotframework
# File: project-root/resources/flows/flows.resource

*** Settings ***
Resource    ../keywords/actions.resource

*** Keywords ***
Search And Preview Item
    [Arguments]    ${search_term}
    Submit Search For Term         ${search_term}
    Select First Item From Results
    Open Item Preview
    Close Preview
```

---

## 5. Test Suite Implementation
The test suite utilizes the infrastructure and flow layers to execute validated scenarios in a human-readable format.

```robotframework
# File: project-root/tests/search_preview_suite.robot

*** Settings ***
Resource          ../resources/common_resource.robot
Resource          ../resources/flows/flows.resource

# Optimization: Launch browser per Suite, Context per Test
Suite Setup       Setup Global Browser
Suite Teardown    Teardown Global Browser
Test Setup        Start UI Test
Test Teardown     Finish UI Test

*** Test Cases ***
Validate Item Preview Flow
    [Documentation]    Ensures search results correctly lead to item preview functionality.
    Navigate To Home Page
    Search And Preview Item    testing
    Verify Price Is Correct    expected price
```

---

## Execution Strategy

Parallel execution is managed via `pabot`. This command initiates multiple browser instances, distributing suites across available CPU cores.

```bash
pabot --processes 5 --outputdir output/ tests/
```

Trace recording is opt-in via command-line variable.

```bash
# Default (no trace)
robot --outputdir output tests/

# Enable trace files per test in output/traces/
robot --outputdir output --variable ENABLE_TRACE:True tests/

# Same toggle with pabot
pabot --processes 5 --outputdir output --variable ENABLE_TRACE:True tests/
```

### Architectural Summary

* **Performance:** Browser processes are persistent across suites, while contexts provide sub-second isolation for individual tests.
* **Traceability:** Trace files are generated only when `ENABLE_TRACE` is set to `True`, stored under Robot's output folder (`${OUTPUT DIR}/traces`), named from a sanitized test-case name (for example `like_a_file_name.zip`), and existing files with the same name are overwritten.
* **Maintainability:** UI modifications require updates only in the centralized locator repository, leaving flow logic and test cases intact.
