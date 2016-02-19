Welcome to My Mysterious Api!
===================

Tests
------------------
**Tested with:**  Ruby2.1 and above  
**Coverage:**  %93  
You can use `rspec` to run tests  
I wrote only controller tests for this project it includes integration and unit tests together for almost any case (64 tests) with the ***coverage of***;

 - **100%** controllers
 - **100%** interactors
 - **100%** models

---------------------------------------------------------------------------------------------------------

Models
------------------
`rake db:migrate` to create tables and schema  
`rake db:seed` to fill initial data to tables

---------------------------------------------------------------------------------------------------------

Authentication
------------------
You can use [devise_token_auth](https://github.com/lynndylanhurley/devise_token_auth)'s sign_in, sign_out or other [routes](https://github.com/lynndylanhurley/devise_token_auth#usage-tldr) for the user actions. I set the token;  "don't change on every request" so when you take client and access-token you don't need to change it on every request.

---------------------------------------------------------------------------------------------------------

Authorization
------------------
I used [pundit](https://github.com/elabs/pundit) gem to authorize system. You can find files under `app/policies`.

---------------------------------------------------------------------------------------------------------

Feel free to contact me if you have questions.  
[onurelibol@gmail.com](mailto:onurelibol@gmail.com)  