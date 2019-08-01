defmodule Seelies.ResourcesAdded do
  @derive Jason.Encoder
  defstruct [:game_id, :territory_id, :quantity]

  def apply(game = %Seelies.Game{territories: territories}, %Seelies.ResourcesAdded{quantity: quantity, territory_id: territory_id}) do
    %{game |
    territories: Enum.reduce(Map.keys(quantity), territories, fn (resource_type, new_territories) ->
      update_in(new_territories, [territory_id, resource_type], fn (count) -> count + quantity[resource_type] end)
    end)}
  end
end


defmodule Seelies.AddResources do
  defstruct [:game_id, :territory_id, :quantity]

  def execute(%Seelies.Game{game_id: game_id, board: board}, %Seelies.AddResources{quantity: quantity, territory_id: territory_id}) do
    cond do
      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      true ->
        %Seelies.ResourcesAdded{game_id: game_id, quantity: quantity, territory_id: territory_id}
    end
  end
end
