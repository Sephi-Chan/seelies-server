defmodule Seelies.Board do
  def new() do
    %{
      areas: %{},
      territories: %{},
      routes: %{},
      borders: %{},
      deposits: %{}
    }
  end


  def add_area(board, area_id) do
    put_in(board, [:areas, area_id], %{deposits: %{}})
  end


  def add_territory(board, territory_id, neighbour_areas) do
    board
      |> put_in([:territories, territory_id], %{area_ids: neighbour_areas})
      |> put_in([:routes, territory_id], %{})
      |> put_in([:borders, territory_id], 1)
  end


  def add_route(board, territory_id, other_territory_id, distance) do
    board
      |> put_in([:routes, territory_id, other_territory_id], distance)
      |> put_in([:routes, other_territory_id, territory_id], distance)
  end


  def add_deposit(board, area_id, deposit_id, type) do
    board
      |> put_in([:areas, area_id, :deposits, deposit_id], type)
      |> put_in([:deposits, deposit_id], %{type: type, area_id: area_id})
  end


  def has_territory?(board, territory_id) do
    Map.has_key?(board.territories, territory_id)
  end


  def has_deposit?(board, deposit_id) do
    Enum.any?(board.areas, fn ({_area_id, area}) -> Map.has_key?(area.deposits, deposit_id) end)
  end


  def is_deposit_in_range?(board, deposit_id, territory_id) do
    area_ids = board.territories[territory_id].area_ids
    Enum.any?(area_ids, fn (area_id) ->
      Map.has_key?(board.areas[area_id].deposits, deposit_id)
    end)
  end
end
