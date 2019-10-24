defmodule Seelies.BaitPlanned do
  @derive Jason.Encoder
  defstruct [:game_id, :territory_id, :area_id, :species, :recurrence, :resources, :time]

  def apply(game = %Seelies.Game{game_id: game_id, territories: territories}, %Seelies.BaitPlanned{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species, resources: resources, recurrence: recurrence, time: time}) do
    %{game | territories: put_in(territories, [territory_id, :baits, {area_id, species}], %{time: time, recurrence: recurrence, resources: resources})}
  end
end


defimpl Commanded.Serialization.JsonDecoder, for: Seelies.BaitPlanned do
  def decode(%Seelies.BaitPlanned{species: species_as_string} = event) do
    %Seelies.BaitPlanned{event | species: String.to_existing_atom(species_as_string)}
  end
end


defmodule Seelies.PlanBait do
  defstruct [:game_id, :territory_id, :area_id, :resources, :player_id, :species, :resources, :recurrence, :time]

  def execute(game = %Seelies.Game{game_id: game_id, board: board}, %Seelies.PlanBait{player_id: player_id, territory_id: territory_id, area_id: area_id, species: species, resources: resources, recurrence: recurrence, time: time}) do
    cond do
      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      not Seelies.Player.can_manage_territory?(game, player_id, territory_id) ->
        {:error, :unauthorized_player}

      not Seelies.Board.is_area_around_territory?(board, area_id, territory_id) ->
        {:error, :invalid_location}

      not Seelies.Board.area_has_species?(board, area_id, species) ->
        {:error, :unavailable_species}

      true ->
        %Seelies.BaitPlanned{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species, resources: resources, recurrence: recurrence, time: time}
    end
  end
end


defmodule Seelies.BaitRemoved do
  @derive Jason.Encoder
  defstruct [:game_id, :territory_id, :area_id, :species]

  def apply(game = %Seelies.Game{game_id: game_id, territories: territories}, %Seelies.BaitRemoved{game_id: game_id, territory_id: territory_id, area_id: area_id, species: species}) do
    %{game | territories: update_in(territories, [territory_id, :baits], fn (baits) -> Map.delete(baits, {area_id, species}) end)}
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
