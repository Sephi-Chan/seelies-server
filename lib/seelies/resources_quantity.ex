defmodule Seelies.ResourcesQuantity do
  @resource_types ["gold", "silver", "bronze"]


  def null do
    Map.new(@resource_types, fn (type) -> {type, 0} end)
  end


  def territory(game, territory_id) do
    game.territories[territory_id]["resources"]
  end


  def convoy(game, convoy_id) do
    game.convoys[convoy_id]["resources"]
  end


  def has_enough?(available_quantity, needed_quantity) do
    not Enum.any?(needed_quantity, fn ({resource_type, needed_amount}) ->
      available_quantity[resource_type] < needed_amount
    end)
  end


  def add(base_quantity, added_quantity) do
    Map.merge(base_quantity, added_quantity, fn (_resource_type, count, other_count) ->
      count + other_count
    end)
  end


  def substract(base_quantity, substracted_quantity) do
    Enum.reduce(substracted_quantity, base_quantity, fn ({resource_type, count}, remaining_quantity) ->
      Map.update!(remaining_quantity, resource_type, fn (initial_count) -> initial_count - count end)
    end)
  end


  def weight(base_quantity, coefficients) do
    Enum.reduce(base_quantity, base_quantity, fn ({resource_type, _count}, weighted_quantity) ->
      coefficient = Map.get(coefficients, resource_type, 1)
      Map.update!(weighted_quantity, resource_type, fn (count) -> count * coefficient end)
    end)
  end
end
