# Session — Add New Test Case

Fill in this form, then paste it into the Copilot chat.
The AI will follow the rules from [create_prompt.md](prompts/create_prompt.md).

---

**Test case name:**
Ikea Testing

**Suite mode:** existing / new
new

**Suite target:**
test_ikea.robot

**Codegen snippet:**

```

import re
from playwright.sync_api import Playwright, sync_playwright, expect


def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()
    page.goto("https://www.ikea.com/")
    page.get_by_role("link", name="Stories").click()
    page.get_by_role("region", name="Cookie banner").click()
    page.get_by_role("link", name="Newsroom").click()
    page.get_by_role("region", name="Cookie banner").click()
    page.get_by_role("link", name="Our business").click()
    page.get_by_role("link", name="Go shopping at IKEA dot n l(").click()
    expect(page.get_by_role("button", name="Products", exact=True)).to_be_visible()

    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)


```
