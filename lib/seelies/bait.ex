defmodule Seelies.Bait do
  def exists?(game, territory_id, area_id, species) do
    Map.has_key?(game.territories[territory_id].baits, {area_id, species})
  end
end
