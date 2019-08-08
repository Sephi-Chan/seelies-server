defmodule Seelies.GameStarted do
  @derive Jason.Encoder
  defstruct [:game_id, :board, :teams]


  def apply(_state, %Seelies.GameStarted{game_id: game_id, board: board, teams: teams}) do
    dispatch = Seelies.Team.dispatch(Enum.map(teams, fn (team) -> team.id end), Map.keys(board.territories))

    %Seelies.Game{
      teams: teams,
      players: Seelies.Team.players_from_teams(teams),
      game_id: game_id,
      board: board,
      units: %{},
      exploitations: %{},
      convoys: %{},
      territories: Enum.reduce(board.territories, %{}, fn ({territory_id, _territory}, acc) ->
        Map.put(acc, territory_id, %{team: dispatch[territory_id], resources: Seelies.ResourcesQuantity.null})
      end)
    }
  end
end


defmodule Seelies.StartGame do
  defstruct [:game_id, :board, :teams]


  def execute(%Seelies.Game{game_id: nil}, %Seelies.StartGame{game_id: game_id, board: board, teams: teams}) do
    %Seelies.GameStarted{game_id: game_id, board: board, teams: teams}
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
