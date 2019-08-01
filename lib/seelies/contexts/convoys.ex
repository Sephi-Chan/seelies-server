defmodule Seelies.ConvoyReadied do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :territory_id]

  def apply(game = %Seelies.Game{convoys: convoys}, %Seelies.ConvoyReadied{convoy_id: convoy_id, territory_id: territory_id}) do
    %{game | convoys: Map.put(convoys, convoy_id, %{territory_id: territory_id, unit_ids: []})}
  end
end


defmodule Seelies.PrepareConvoy do
  defstruct [:game_id, :convoy_id, :territory_id]

  def execute(%Seelies.Game{game_id: game_id, board: board}, %Seelies.PrepareConvoy{convoy_id: convoy_id, territory_id: territory_id}) do
    cond do
      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      true ->
        %Seelies.ConvoyReadied{game_id: game_id, convoy_id: convoy_id, territory_id: territory_id}
    end
  end
end


defmodule Seelies.UnitJoinedConvoy do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :unit_id]

  def apply(game = %Seelies.Game{units: units, convoys: convoys}, %Seelies.UnitJoinedConvoy{unit_id: unit_id, convoy_id: convoy_id}) do
    %{game |
      units: put_in(units, [unit_id, :convoy_id], convoy_id),
      convoys: update_in(convoys, [convoy_id, :unit_ids], fn (unit_ids) -> [unit_id|unit_ids] end)}
  end
end


defmodule Seelies.UnitJoinsConvoy do
  defstruct [:game_id, :convoy_id, :unit_id]

  def execute(%Seelies.Game{game_id: game_id, exploitations: exploitations, convoys: convoys, units: units}, %Seelies.UnitJoinsConvoy{convoy_id: convoy_id, unit_id: unit_id}) do
    cond do
      convoys[convoy_id] == nil ->
        {:error, :convoy_not_found}

      units[unit_id] == nil ->
        {:error, :unit_not_found}

      units[unit_id].convoy_id == convoy_id ->
        {:error, :already_joined}

      exploitations[unit_id] != nil ->
        {:error, :unavailable_unit}

      convoys[convoy_id].territory_id != units[unit_id].territory_id ->
        {:error, :convoy_too_far}

      true ->
        %Seelies.UnitJoinedConvoy{game_id: game_id, convoy_id: convoy_id, unit_id: unit_id}
    end
  end
end


defmodule Seelies.UnitLeftConvoy do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :unit_id]

  def apply(game = %Seelies.Game{units: units, convoys: convoys}, %Seelies.UnitLeftConvoy{unit_id: unit_id, convoy_id: convoy_id}) do
    %{game |
      units: put_in(units, [unit_id, :convoy_id], nil),
      convoys: update_in(convoys, [convoy_id, :unit_ids], fn (unit_ids) -> List.delete(unit_ids, unit_id) end)}
  end
end


defmodule Seelies.UnitLeavesConvoy do
  defstruct [:game_id, :convoy_id, :unit_id]

  def execute(%Seelies.Game{game_id: game_id, convoys: convoys, units: units}, %Seelies.UnitLeavesConvoy{convoy_id: convoy_id, unit_id: unit_id}) do
    cond do
      convoys[convoy_id] == nil ->
        {:error, :convoy_not_found}

      units[unit_id] == nil ->
        {:error, :unit_not_found}

      units[unit_id].convoy_id != convoy_id ->
        {:error, :not_in_convoy}

      true ->
        %Seelies.UnitLeftConvoy{game_id: game_id, convoy_id: convoy_id, unit_id: unit_id}
    end

  end
end
