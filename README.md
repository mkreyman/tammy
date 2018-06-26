Tammy
=====
    
> [tammy](http://www.dictionary.com/browse/tammy) -- also called: tammy cloth, tamis (esp formerly) a rough-textured woollen cloth used for straining sauces, soups, etc

This is an application to be used with [SendGrid's Parse API]. It takes POST'ed email message, parses it, and forwards it to an email address of your choice using [Bamboo](https://github.com/thoughtbot/bamboo) as SMTP client.

[SendGrid's Parse API]: http://sendgrid.com/docs/API_Reference/Webhooks/parse.html

Configuration
-------------

  * Configure system env variables `SENDGRID_FROM_ADDRESS`, `SENDGRID_FORWARDERS` and `SENDGRID_API_KEY` (see defaults in `config/config.exs` and `config/prod.exs` for examples). Value for the `SENDGRID_FORWARDERS` variable is a JSON-encoded elixir map where keys are recipients' email addresses and values are corresponding email addresses that posted email messages should be sent to. If no match is found, then the posted message gets discarded.
  * Configure your SendGrid > Settings Inbound Parse, i.e. `HOST: yourdomain.com, URL: https://pure-heart-97531.herokuapp.com/parse` (keep "spam check" and "send raw" unchecked).

To test locally
---------------

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`
  * POST your multi-part message to [`localhost:4000/parse`](http://localhost:4000/parse) using Postman or another client. A sample payload could be found at this [SendGrid page](https://sendgrid.com/docs/Classroom/Basics/Inbound_Parse_Webhook/setting_up_the_inbound_parse_webhook.html#-Example-Default-Payload).
  * `dev` environment is configured to use a local adapter, so your triggered emails won't actually be sent. However, they could be seen at [`localhost:4000/sent_emails`](http://localhost:4000/sent_emails). Notice that the local adapter would not display any email attachments.

To deploy and test on Heroku
----------------------------

  * [The Heroku Deployment page on hexdocs](https://hexdocs.pm/phoenix/heroku.html) provides pretty accurate instructions. Just do NOT add Phoenix Static Buildpack. You don't need it for this application as there are no static assets to compile. And trying to install `node/npm` would likely just mess up your deployment.


Enjoy! :)
