defmodule Seelies.Bait do
  def exists?(game, territory_id, area_id, species) do
    Map.has_key?(game.territories[territory_id].baits, {area_id, species})
  end


  # bait_tuple: {resources_quantity, timestamp, territory_id}
  def bait_tuples_for_area(game, area_id, species) do
    Enum.reduce(Seelies.Board.territories_around_area(game.board, area_id), [], fn (territory_id, bait_tuples) ->
      bait = game.territories[territory_id].baits[{area_id, species}]
      if bait do [{bait, 0, territory_id}|bait_tuples] else bait_tuples end
    end)
  end


  def find_highest_baiter_territory([], _coefficients), do: nil

  def find_highest_baiter_territory(bait_tuples, coefficients) do
    bait_tuples_with_value = Enum.map(bait_tuples, fn ({resources_quantity, _timestamp, _territory_id} = bait_tuple) ->
      weighted_resources_quantity = Seelies.ResourcesQuantity.weight(resources_quantity, coefficients)
      {bait_tuple, Enum.sum(Map.values(weighted_resources_quantity))}
    end)

    highest_value = Enum.reduce(bait_tuples_with_value, 0, fn ({_bait_tuple, value}, highest_value) ->
      if value > highest_value do value else highest_value end
    end)

    winners = Enum.filter(bait_tuples_with_value, fn ({_bait_tuple, value}) ->
      value == highest_value
    end)

    {winner_bait_tuple, _value} = Enum.min_by(winners, fn ({{_resources_quantity, timestamp, _territory_id}, _value}) -> timestamp end)
    winner_bait_tuple
  end
end
