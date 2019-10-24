defmodule Seelies.Unit do
  @resources_per_minute %{
    ant:    %{gold: 10, silver: 10},
    beetle: %{gold: 10, silver: 10},
    wasp:   %{gold: 10, silver: 10}
  }

  @metres_per_hour %{
    ant: 10,
    beetle: 7,
    wasp: 30
  }


  @training_durations %{ # In seconds.
    ant: 3 * 60,
    beetle: 10 * 60,
    wasp: 10 * 60
  }


  @resources_preferences_coefficients %{ # Coefficients used in the weighting. Default is 1.
    ant: %{gold: 1, silver: 1, bronze: 1},
    beetle: %{gold: 1, silver: 1, bronze: 1},
    wasp: %{gold: 1, silver: 1, bronze: 1}
  }


  def uuid() do
    "unit-" <> Ecto.UUID.generate()
  end


  def resources_per_second(species, resource_type) do
    @resources_per_minute[species][resource_type]/60
  end


  def metres_per_hour(species) do
    @metres_per_hour[species]
  end


  def training_durations(species) do
    @training_durations[species]
  end


  def resources_preferences_coefficients(species) do
    @resources_preferences_coefficients[species]
  end


  def slowest(game, unit_ids) do
    Enum.reduce(unit_ids, {nil, 0}, fn (unit_id, {slowest_unit_id, slowest_unit_speed}) ->
      speed = Seelies.Unit.metres_per_hour(game.units[unit_id].species)
      cond do
        slowest_unit_id == nil -> {unit_id, speed}
        speed < slowest_unit_speed -> {unit_id, speed}
        true -> {slowest_unit_id, slowest_unit_speed}
      end
    end)
  end


  def exists?(%Seelies.Game{units: units}, unit_id) do
    units[unit_id] != nil
  end


  def exploiting?(%Seelies.Game{exploitations: exploitations}, unit_id) do
    exploitations[unit_id] != nil
  end


  def convoying?(%Seelies.Game{units: units}, unit_id) do
    units[unit_id].convoy_id != nil
  end


  def belongs_to_convoy?(%Seelies.Game{units: units}, unit_id, convoy_id) do
    units[unit_id].convoy_id == convoy_id
  end
end
