defmodule Seelies.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Seelies.Repo, []},
      {Seelies.ExploitationTicksHandler, []},
      # {Seelies.EventStore, []}
    ]

    opts = [strategy: :one_for_one, name: Seelies.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
