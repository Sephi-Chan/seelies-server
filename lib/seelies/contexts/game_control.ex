defmodule Seelies.GameStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :board]


  def apply(_state, %Seelies.GameStarted{game_id: game_id, board: board}) do
    %Seelies.Game{
      game_id: game_id,
      board: board,
      units: %{},
      exploitations: %{},
      convoys: %{},
      territories: Enum.reduce(board.territories, %{}, fn ({territory_id, _territory}, acc) ->
        Map.put(acc, territory_id, %{resources: Seelies.ResourcesQuantity.null})
      end)
    }
  end
end


defmodule Seelies.StartGame do
  defstruct [:game_id, :board]


  def execute(%Seelies.Game{game_id: nil}, %Seelies.StartGame{game_id: game_id, board: board}) do
    %Seelies.GameStarted{game_id: game_id, board: board}
  end


  def execute(%Seelies.Game{}, %Seelies.StartGame{}) do
    {:error, :game_already_exists}
  end
end


defmodule Seelies.GameStopped do
  @derive Jason.Encoder
  defstruct [:game_id, :board]


  def apply(game, %Seelies.GameStopped{}) do
    game
  end
end



defmodule Seelies.StopGame do
  defstruct [:game_id]


  def execute(%Seelies.Game{game_id: game_id}, %Seelies.StopGame{}) do
    %Seelies.GameStopped{game_id: game_id}
  end
end
