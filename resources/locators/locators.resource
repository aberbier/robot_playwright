*** Settings ***
# data-test-id locators single point of maintenance

*** Variables ***
&{LOGIN}
...    username_field=internal:role=textbox[name="Username"i]
...    password_field=internal:role=textbox[name="Password"i]
...    login_btn=internal:role=button[name="Login"s]

&{WIKIPEDIA_HOME}
...    anniversary_banner=id=wikipedia25-cta-button
...    encyclopedia_hero_text=text=Wikipedia The Free Encyclopedia Wikipedia 25 years of the free encyclopedia
...    english_articles_link=internal:role=link[name="English 7,141,000+ articles"i]

&{WIKIPEDIA_EN}
...    main_menu_btn=internal:role=button[name="Main menu"i]
...    random_article_link=internal:role=link[name="Random article"i]
...    search_btn=internal:role=button[name="Search"i]

&{IKEA_HOME}
...    stories_link=internal:role=link[name="Stories"i]
...    cookie_banner=internal:role=region[name="Cookie banner"i]
...    our_business_link=internal:role=link[name="Our business"i]
...    go_shopping_link=internal:role=link[name="Go shopping at IKEA dot n l("i]
...    products_button=internal:role=button[name="Products"i]
