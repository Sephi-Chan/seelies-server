ExUnit.start()

defmodule InMemoryEventStoreCase do
  use ExUnit.CaseTemplate

  setup do
    on_exit(fn ->
      :ok = Application.stop(:seelies)
      :ok = Application.stop(:commanded)
      :ok = Application.stop(:commanded_scheduler)

      {:ok, _apps} = Application.ensure_all_started(:seelies)
    end)
  end
end
