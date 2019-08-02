defmodule Seelies.Unit do
  @resources_per_minute %{
    ant:    %{ gold: 10, silver: 10 },
    beetle: %{ gold: 10, silver: 10 },
    wasp:   %{ gold: 10, silver: 10 }
  }

  @metres_per_hour %{
    ant: 10,
    beetle: 7,
    wasp: 30
  }


  def resources_per_second(species, resource_type) do
    @resources_per_minute[species][resource_type]/60
  end


  def metres_per_hour(species) do
    @metres_per_hour[species]
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
end
