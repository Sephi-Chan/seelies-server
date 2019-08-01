defmodule Seelies.ResourcesQuantity do
  def null do
    %{
      gold: 0,
      silver: 0,
      bronze: 0
    }
  end


  def territory(game, territory_id) do
    game.territories[territory_id].resources
  end


  def convoy(game, convoy_id) do
    game.convoys[convoy_id].resources
  end


  def has_enough?(available_quantity, needed_quantity) do
    Enum.all?(needed_quantity, fn ({resource_type, quantity}) ->
      available_quantity[resource_type] <= quantity
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
end
