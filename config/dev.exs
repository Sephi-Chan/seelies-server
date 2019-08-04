import Config

config :mix_test_watch, clear: true

config :seelies, Seelies.Repo,
  database: "seelies_dev",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost"

config :commanded_scheduler, Commanded.Scheduler.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "seelies_dev",
  username: "seelies",
  password: "b?t>J0yD{8<1",
  hostname: "localhost",
  pool_size: 1
