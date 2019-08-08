import Config

config :seelies,
  ecto_repos: [Seelies.Repo, Commanded.Scheduler.Repo]

config :commanded_scheduler,
  router: Seelies.Router

import_config "#{Mix.env()}.exs"
