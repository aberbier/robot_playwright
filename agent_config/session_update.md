# Session — Update Existing Test Case

Fill in this form, then paste it into the Copilot chat.
The AI will follow the rules from [update_prompt.md](prompts/update_prompt.md).

---

**Test case to update:**

Ikea Testing

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
    expect(page.get_by_role("button", name="Products", exact=True)).to_be_visible()
    page.get_by_role("button", name="Products", exact=True).click()
    page.get_by_role("button", name="Rooms", exact=True).click()
    page.get_by_role("button", name="Bargains").click()
    page.get_by_role("button", name="Design").click()
    page.get_by_role("button", name="Services").click()
    page.get_by_role("button", name="Products", exact=True).click()
    page.get_by_role("tab", name="New", exact=True).click()
    page.get_by_role("tab", name="Baby & children's products").click()
    page.get_by_role("tab", name="Cooking & Eating").click()
    page.get_by_role("tab", name="Cabinets").click()
    page.get_by_role("link", name="Hall furniture").click()
    page.get_by_role("button", name="Bargains").click()
    page.get_by_role("button", name="Services").click()
    page.get_by_label("Services", exact=True).get_by_role("link", name="Maintenance & repair").click()
    page.get_by_role("button", name="Design").click()
    page.get_by_role("link", name="Schedule your kitchen").click()
    page.get_by_role("button", name="Rooms").click()
    page.get_by_role("link", name="Bedroom").click()
    page.get_by_role("button", name="Products").click()
    page.get_by_label("IKEA & you").get_by_role("link", name="IKEA stores").click()
    page.get_by_role("button", name="Products").click()
    page.get_by_role("button", name="Bargains").click()
    page.get_by_role("button", name="Design").click()
    page.get_by_role("button", name="Design").click()
    page.get_by_role("button", name="Products").click()
    expect(page.get_by_role("button", name="Bargains")).to_be_visible()

    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)

```
