# test/support/data_case.ex
defmodule Seelies.Test.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Commanded.Assertions.EventAssertions
    end
  end

  setup do
    {:ok, _} = Application.ensure_all_started(:seelies)

    on_exit(fn ->
      :ok = Application.stop(:seelies)
      :ok = Application.stop(:commanded)
      :ok = Application.stop(:eventstore)

      Seelies.Test.Storage.reset!()
    end)

    :ok
  end
end


# test/support/storage.ex
defmodule Seelies.Test.Storage do
  # Clear the event store and read store databases
  def reset! do
    reset_eventstore()
    # reset_readstore()
  end

  defp reset_eventstore do
    config = EventStore.Config.parsed() |> EventStore.Config.default_postgrex_opts()
    {:ok, conn} = Postgrex.start_link(config)
    EventStore.Storage.Initializer.reset!(conn)
  end

  # defp reset_readstore do
  #   config = Application.get_env(:seelies, Seelies.Repo)
  #   {:ok, conn} = Postgrex.start_link(config)
  #   Postgrex.query!(conn, truncate_readstore_tables(), [])
  # end

  # defp truncate_readstore_tables do
  #   """
  #   TRUNCATE TABLE
  #     table1,
  #     table2,
  #     table3
  #   RESTART IDENTITY
  #   CASCADE;
  #   """
  # end
end
