defmodule Seelies.BaitDeployed do
  @derive Jason.Encoder
  defstruct [:game_id, :territory_id, :area_id, :species, :resources]

  def apply(game = %Seelies.Game{game_id: game_id, territories: territories}, %Seelies.BaitDeployed{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species, resources: resources}) do
    %{game |
      territories: territories
        |> update_in([territory_id, :resources], fn (stored_resources) -> Seelies.ResourcesQuantity.substract(stored_resources, resources) end)
        |> put_in([territory_id, :baits, {area_id, species}], resources)}
  end
end


defimpl Commanded.Serialization.JsonDecoder, for: Seelies.BaitDeployed do
  def decode(%Seelies.BaitDeployed{species: species_as_string} = event) do
    %Seelies.BaitDeployed{event | species: String.to_existing_atom(species_as_string)}
  end
end


defmodule Seelies.DeployBait do
  defstruct [:game_id, :territory_id, :area_id, :resources, :player_id, :species, :resources]

  def execute(game = %Seelies.Game{game_id: game_id, board: board}, %Seelies.DeployBait{player_id: player_id, territory_id: territory_id, area_id: area_id, species: species, resources: resources}) do
    cond do
      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      not Seelies.Player.can_manage_territory?(game, player_id, territory_id) ->
        {:error, :unauthorized_player}

      not Seelies.Board.is_area_around_territory?(board, area_id, territory_id) ->
        {:error, :invalid_location}

      not Seelies.Board.area_has_species?(board, area_id, species) ->
        {:error, :unavailable_species}

      not Seelies.ResourcesQuantity.has_enough?(game.territories[territory_id].resources, resources) ->
        {:error, :not_enough_resources}

      Seelies.Bait.exists?(game, territory_id, area_id, species) ->
        {:error, :bait_already_set}

      true ->
        %Seelies.BaitDeployed{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species, resources: resources}
    end
  end
end


defmodule Seelies.BaitRemoved do
  @derive Jason.Encoder
  defstruct [:game_id, :territory_id, :area_id, :species]

  def apply(game = %Seelies.Game{game_id: game_id, territories: territories}, %Seelies.BaitRemoved{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species}) do
    retrieved_resources = territories[territory_id].baits[{area_id, species}]
    %{game |
      territories: territories
        |> update_in([territory_id, :resources], fn (stored_resources) -> Seelies.ResourcesQuantity.add(stored_resources, retrieved_resources) end)
        |> update_in([territory_id, :baits], fn (baits) -> Map.delete(baits, {area_id, species}) end)}
  end
end




defimpl Commanded.Serialization.JsonDecoder, for: Seelies.BaitRemoved do
  def decode(%Seelies.BaitRemoved{species: species_as_string} = event) do
    %Seelies.BaitRemoved{event | species: String.to_existing_atom(species_as_string)}
  end
end



defmodule Seelies.RemoveBait do
  defstruct [:game_id, :territory_id, :area_id, :resources, :player_id, :species]

  def execute(game = %Seelies.Game{game_id: game_id, board: board}, %Seelies.RemoveBait{player_id: player_id, territory_id: territory_id, area_id: area_id, species: species}) do
    cond do
      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      not Seelies.Player.can_manage_territory?(game, player_id, territory_id) ->
        {:error, :unauthorized_player}

      not Seelies.Bait.exists?(game, territory_id, area_id, species) ->
        {:error, :bait_not_found}

      true ->
        %Seelies.BaitRemoved{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species}
    end
  end
end
