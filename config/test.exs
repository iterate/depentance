import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :depentance, DepentanceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "O7rDHb0kVwfFTvsM/0ycjXb9QU/44LnzRlCrc0BdANPLS+5KYEJr/59rcNWCyTNn",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
