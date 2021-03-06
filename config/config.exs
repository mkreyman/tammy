# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tammy, ecto_repos: [Tammy.Repo]

# Configures the endpoint
config :tammy, TammyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I9O/rlP6xi1jtdFPaH3aM0EV//yczsyh8kaVlSJFmHco/Evo9FprSi02FWxPVSPG",
  render_errors: [view: TammyWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Tammy.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :briefly,
  directory: [{:system, "TMPDIR"}, {:system, "TMP"}, {:system, "TEMP"}, "/tmp"],
  default_prefix: "original",
  default_extname: ".html"

# Configure Tammy.Filter with forwarding map
config :tammy,
  from_address: System.get_env("SENDGRID_FROM_ADDRESS") || "test@example.com",
  filter:
    System.get_env("SENDGRID_FORWARDERS") ||
      "{\"original@example.com\":\"forwarder@example.com\"}"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
