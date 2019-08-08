defmodule Seelies.Territory do
  def exists?(%Seelies.Game{territories: territories}, territory_id) do
    territories[territory_id] != nil
  end
end
