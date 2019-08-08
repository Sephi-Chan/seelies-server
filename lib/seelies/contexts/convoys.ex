defmodule Seelies.ConvoyReadied do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :territory_id]

  def apply(game = %Seelies.Game{convoys: convoys}, %Seelies.ConvoyReadied{convoy_id: convoy_id, territory_id: territory_id}) do
    convoy = %{territory_id: territory_id, unit_ids: [], resources: Seelies.ResourcesQuantity.null, destination_territory_id: nil}
    %{game | convoys: Map.put(convoys, convoy_id, convoy)}
  end
end


defmodule Seelies.PrepareConvoy do
  defstruct [:game_id, :convoy_id, :territory_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id, board: board}, %Seelies.PrepareConvoy{convoy_id: convoy_id, territory_id: territory_id, player_id: player_id}) do
    cond do
      Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_already_exists}

      not Seelies.Board.has_territory?(board, territory_id) ->
        {:error, :territory_not_found}

      not Seelies.Player.can_manage_territory?(game, player_id, territory_id) ->
        {:error, :unauthorized_player}

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
  defstruct [:game_id, :convoy_id, :unit_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id}, %Seelies.UnitJoinsConvoy{convoy_id: convoy_id, unit_id: unit_id, player_id: player_id}) do
    cond do
      not Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_not_found}

      not Seelies.Unit.exists?(game, unit_id) ->
        {:error, :unit_not_found}

      Seelies.Unit.belongs_to_convoy?(game, unit_id, convoy_id) ->
        {:error, :already_joined}

      Seelies.Unit.exploiting?(game, unit_id) ->
        {:error, :busy_exploiting}

      not Seelies.Player.can_control_unit?(game, player_id, unit_id) ->
        {:error, :unauthorized_player}

      not Seelies.Convoy.is_near_unit?(game, convoy_id, unit_id) ->
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
  defstruct [:game_id, :convoy_id, :unit_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id}, %Seelies.UnitLeavesConvoy{convoy_id: convoy_id, unit_id: unit_id, player_id: player_id}) do
    cond do
      not Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_not_found}

      not Seelies.Unit.exists?(game, unit_id) ->
        {:error, :unit_not_found}

      not Seelies.Unit.belongs_to_convoy?(game, unit_id, convoy_id) ->
        {:error, :not_in_convoy}

      not Seelies.Player.can_control_unit?(game, player_id, unit_id) ->
        {:error, :unauthorized_player}

      true ->
        %Seelies.UnitLeftConvoy{game_id: game_id, convoy_id: convoy_id, unit_id: unit_id}
    end

  end
end


defmodule Seelies.ResourcesLoadedIntoConvoy do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :resources]

  def apply(game = %Seelies.Game{game_id: game_id, convoys: convoys, territories: territories}, %Seelies.ResourcesLoadedIntoConvoy{game_id: game_id, convoy_id: convoy_id, resources: resources}) do
    %{game |
      convoys: update_in(convoys, [convoy_id, :resources], fn (carried_resources) -> Seelies.ResourcesQuantity.add(carried_resources, resources) end),
      territories: update_in(territories, [convoys[convoy_id].territory_id, :resources], fn (stored_resources) -> Seelies.ResourcesQuantity.substract(stored_resources, resources) end)}
  end
end


defmodule Seelies.LoadResourcesIntoConvoy do
  defstruct [:game_id, :resources, :convoy_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id, convoys: convoys, territories: territories}, %Seelies.LoadResourcesIntoConvoy{convoy_id: convoy_id, resources: resources, player_id: player_id}) do
    cond do
      not Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_not_found}

      not Seelies.ResourcesQuantity.has_enough?(territories[convoys[convoy_id].territory_id].resources, resources) ->
        {:error, :not_enough_resources}

      not Seelies.Player.can_manage_convoy?(game, player_id, convoy_id) ->
        {:error, :unauthorized_player}

      true ->
        %Seelies.ResourcesLoadedIntoConvoy{game_id: game_id, convoy_id: convoy_id, resources: resources}
    end
  end
end


defmodule Seelies.ResourcesUnloadedFromConvoy do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :resources]

  def apply(game = %Seelies.Game{game_id: game_id, convoys: convoys, territories: territories}, %Seelies.ResourcesUnloadedFromConvoy{game_id: game_id, convoy_id: convoy_id, resources: unloaded_resources}) do
    %{game |
      convoys: update_in(convoys, [convoy_id, :resources], fn (carried_resources) -> Seelies.ResourcesQuantity.substract(carried_resources, unloaded_resources) end),
      territories: update_in(territories, [convoys[convoy_id].territory_id, :resources], fn (stored_resources) -> Seelies.ResourcesQuantity.add(stored_resources, unloaded_resources) end)}
  end
end


defmodule Seelies.UnloadResourcesFromConvoy do
  defstruct [:game_id, :resources, :convoy_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id, convoys: convoys}, %Seelies.UnloadResourcesFromConvoy{convoy_id: convoy_id, resources: unloaded_resources, player_id: player_id}) do
    cond do
      not Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_not_found}

      not Seelies.ResourcesQuantity.has_enough?(convoys[convoy_id].resources, unloaded_resources) ->
        {:error, :not_enough_resources}

      not Seelies.Player.can_manage_convoy?(game, player_id, convoy_id) ->
        {:error, :unauthorized_player}

      true ->
        %Seelies.ResourcesUnloadedFromConvoy{game_id: game_id, convoy_id: convoy_id, resources: unloaded_resources}
    end
  end
end


defmodule Seelies.ConvoyStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id, :destination_territory_id, :duration]

  def apply(game = %Seelies.Game{convoys: convoys}, %Seelies.ConvoyStarted{convoy_id: convoy_id, destination_territory_id: destination_territory_id}) do
    %{game | convoys: put_in(convoys, [convoy_id, :destination_territory_id], destination_territory_id)}
  end
end


defmodule Seelies.ConvoyStarts do
  defstruct [:game_id, :convoy_id, :destination_territory_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id, convoys: convoys, board: board}, %Seelies.ConvoyStarts{convoy_id: convoy_id, destination_territory_id: destination_territory_id, player_id: player_id}) do
    cond do
      not Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_not_found}

      not Seelies.Convoy.has_unit?(game, convoy_id) ->
        {:error, :no_unit}

      not Seelies.Territory.exists?(game, destination_territory_id) ->
        {:error, :territory_not_found}

      Seelies.Convoy.started?(game, convoy_id) ->
        {:error, :already_started}

      not Seelies.Board.has_route_between?(board, convoys[convoy_id].territory_id, destination_territory_id) ->
        {:error, :territory_too_far}

      not Seelies.Player.can_manage_convoy?(game, player_id, convoy_id) ->
        {:error, :unauthorized_player}

      true ->
        {_slowest_unit_id, slowest_unit_speed} = Seelies.Unit.slowest(game, convoys[convoy_id].unit_ids) # 7 metres per hour (beetle)
        distance = Seelies.Board.distance_between_territories(board, convoys[convoy_id].territory_id, destination_territory_id) # 10 metres
        duration = Float.round(distance * 3600 / slowest_unit_speed)

        %Seelies.ConvoyStarted{game_id: game_id, convoy_id: convoy_id, destination_territory_id: destination_territory_id, duration: duration}
    end
  end
end


defmodule Seelies.ConvoyReachedDestination do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id]

  def apply(game = %Seelies.Game{convoys: convoys, territories: territories}, %Seelies.ConvoyReachedDestination{convoy_id: convoy_id}) do
    territory_id = convoys[convoy_id].destination_territory_id
    %{game |
      units: Enum.reduce(convoys[convoy_id].unit_ids, game.units, fn (unit_id, units) ->
        units
          |> put_in([unit_id, :convoy_id], nil)
          |> put_in([unit_id, :territory_id], territory_id)
      end),
      territories: update_in(territories, [territory_id, :resources], fn (stored_resources) -> Seelies.ResourcesQuantity.add(stored_resources, convoys[convoy_id].resources) end),
      convoys: Map.delete(convoys, convoy_id)}
  end
end


defmodule Seelies.ConvoyReachesDestination do
  defstruct [:game_id, :convoy_id]

  def execute(%Seelies.Game{game_id: game_id}, %Seelies.ConvoyReachesDestination{convoy_id: convoy_id}) do
    %Seelies.ConvoyReachedDestination{game_id: game_id, convoy_id: convoy_id}
  end
end



defmodule Seelies.ConvoyDisbanded do
  @derive Jason.Encoder
  defstruct [:game_id, :convoy_id]

  def apply(game = %Seelies.Game{convoys: convoys, territories: territories}, %Seelies.ConvoyDisbanded{convoy_id: convoy_id}) do
    %{game |
      units: Enum.reduce(convoys[convoy_id].unit_ids, game.units, fn (unit_id, units) ->
        put_in(units, [unit_id, :convoy_id], nil)
      end),
      territories: update_in(territories, [convoys[convoy_id].territory_id, :resources], fn (stored_resources) -> Seelies.ResourcesQuantity.add(stored_resources, convoys[convoy_id].resources) end),
      convoys: Map.delete(convoys, convoy_id)}
  end
end


defmodule Seelies.DisbandConvoy do
  defstruct [:game_id, :convoy_id, :player_id]

  def execute(game = %Seelies.Game{game_id: game_id}, %Seelies.DisbandConvoy{convoy_id: convoy_id, player_id: player_id}) do
    cond do
      not Seelies.Convoy.exists?(game, convoy_id) ->
        {:error, :convoy_not_found}

      Seelies.Convoy.started?(game, convoy_id) ->
        {:error, :already_started}

      not Seelies.Player.can_manage_convoy?(game, player_id, convoy_id) ->
        {:error, :unauthorized_player}

      true ->
        %Seelies.ConvoyDisbanded{game_id: game_id, convoy_id: convoy_id}
    end
  end
end
