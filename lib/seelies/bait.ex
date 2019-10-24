defmodule Seelies.Bait do
  def exists?(game, territory_id, area_id, species) do
    Map.has_key?(game.territories[territory_id].baits, {area_id, species})
  end


  # bait_tuple: {%{resources: resources_quantity, time: int, recurrence: int}, territory_id}
  def bait_tuples_for_area(game, area_id, species) do
    Enum.reduce(Seelies.Board.territories_around_area(game.board, area_id), [], fn (territory_id, bait_tuples) ->
      bait = game.territories[territory_id].baits[{area_id, species}]
      if bait do [{bait, territory_id}|bait_tuples] else bait_tuples end
    end)
  end


  def sorted_baiters(bait_tuples, coefficients) do
    bait_tuples_with_value = Enum.map(bait_tuples, fn ({%{resources: resources_quantity}, _territory_id} = bait_tuple) ->
      weighted_resources_quantity = Seelies.ResourcesQuantity.weight(resources_quantity, coefficients)
      {bait_tuple, Enum.sum(Map.values(weighted_resources_quantity))}
    end)

    Enum.sort_by(bait_tuples_with_value,  fn ({{%{time: time}, _territory_id}, value}) -> {-value, time} end)
  end
end
