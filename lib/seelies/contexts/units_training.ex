defmodule Seelies.UnitTrainingStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :area_id, :species, :unit_id, :duration]

  def apply(game = %Seelies.Game{}, %Seelies.UnitTrainingStarted{}) do
    game
  end
end


defimpl Commanded.Serialization.JsonDecoder, for: Seelies.UnitTrainingStarted do
  def decode(%Seelies.UnitTrainingStarted{species: species_as_string} = event) do
    %Seelies.UnitTrainingStarted{event | species: String.to_existing_atom(species_as_string)}
  end
end


defmodule Seelies.StartUnitTraining do
  defstruct [:game_id, :area_id, :species]

  def execute(%Seelies.Game{game_id: game_id, board: board}, %Seelies.StartUnitTraining{area_id: area_id, species: species}) do
    cond do
      not Seelies.Board.area_has_species?(board, area_id, species) ->
        {:error, :unavailable_species}

      true ->
        %Seelies.UnitTrainingStarted{game_id: game_id, area_id: area_id, species: species, unit_id: Seelies.Unit.uuid(), duration: Seelies.Unit.training_durations(species)}
    end
  end
end


defmodule Seelies.UnitSpawned do
  @derive Jason.Encoder
  defstruct [:game_id, :area_id, :territory_id, :unit_id, :species]

  def apply(game = %Seelies.Game{units: units}, %Seelies.UnitSpawned{territory_id: territory_id, unit_id: unit_id, species: species}) do
    unit = %{unit_id: unit_id, species: species, territory_id: territory_id, convoy_id: nil}
    %{game | units: Map.put(units, unit_id, unit)}
  end
end


defmodule Seelies.SpawnUnit do
  defstruct [:game_id, :area_id, :unit_id, :species]

  def execute(%Seelies.Game{game_id: game_id} = game, %Seelies.SpawnUnit{area_id: area_id, unit_id: unit_id, species: species}) do
    bait_tuples = Seelies.Bait.bait_tuples_for_area(game, area_id, species)
    coefficients = Seelies.Unit.resources_preferences_coefficients(species)
    {_resources_quantity, _timestamp, chosen_territory_id} = Seelies.Bait.find_highest_baiter_territory(bait_tuples, coefficients)

    %Seelies.UnitSpawned{game_id: game_id, area_id: area_id, territory_id: chosen_territory_id, unit_id: unit_id, species: species}
  end
end


defmodule Seelies.UnitsSpawner do
  use Commanded.Event.Handler, name: __MODULE__, start_from: :current


  def handle(%Seelies.UnitTrainingStarted{game_id: game_id, area_id: area_id, species: species, unit_id: unit_id, duration: duration}, _metadata) do
    due_at = DateTime.add(DateTime.utc_now(), duration, :second)
    Commanded.Scheduler.schedule_once(Ecto.UUID.generate(), %Seelies.SpawnUnit{game_id: game_id, area_id: area_id, unit_id: unit_id, species: species}, due_at)
  end
end
