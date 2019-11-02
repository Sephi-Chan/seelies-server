defmodule Seelies.StartingUnitDeployed do
  @derive Jason.Encoder
  defstruct [:game_id, :territory_id, :unit_id, :species]

  def apply(game = %Seelies.Game{units: units}, %Seelies.StartingUnitDeployed{territory_id: territory_id, unit_id: unit_id, species: species}) do
    unit = %{
      "unit_id" => unit_id,
      "species" => species,
      "territory_id" => territory_id,
      "convoy_id" => nil
    }
    %{game | units: Map.put(units, unit_id, unit)}
  end
end


defmodule Seelies.DeployStartingUnit do
  defstruct [:game_id, :territory_id, :unit_id, :species]

  def execute(%Seelies.Game{game_id: game_id, units: units, board: board}, %Seelies.DeployStartingUnit{territory_id: territory_id, unit_id: unit_id, species: species}) do
    cond do
      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      units[unit_id] != nil ->
        {:error, :unit_already_exists}

      true ->
        %Seelies.StartingUnitDeployed{game_id: game_id, territory_id: territory_id, unit_id: unit_id, species: species}
    end
  end
end
