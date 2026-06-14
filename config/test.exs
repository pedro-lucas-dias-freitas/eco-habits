import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :pbkdf2_elixir, :rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :eco_habits, EcoHabits.Repo,
  adapter: Ecto.Adapters.MyXQL,
  username: "root",
  password: "senha123banco",
  hostname: "localhost",
  database: "eco_habits_test#{System.get_env("HEX_POOL_SIZE")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.get_env("HEX_POOL_SIZE") || 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :eco_habits, EcoHabitsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mjmhit6Z9PFzkLHqU3hqdBMDlkxz8MOcSXshg+26vWz71BpS8b6UDdZz0RV33LYI",
  server: false

# In test we don't send emails
config :eco_habits, EcoHabits.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
