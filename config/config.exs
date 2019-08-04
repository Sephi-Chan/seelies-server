import Config

config :seelies, ecto_repos: [Seelies.Repo, Commanded.Scheduler.Repo]

import_config "#{Mix.env()}.exs"
