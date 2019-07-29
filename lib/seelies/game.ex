
defmodule Seelies.Game do
  defstruct [:game_id, :board, :units, :exploitations, :territories]


  def execute(game, command = %Seelies.StartGame{}) do Seelies.StartGame.execute(game, command) end
  def execute(game, command = %Seelies.DeployStartingUnit{}) do Seelies.DeployStartingUnit.execute(game, command) end
  def execute(game, command = %Seelies.UnitStartsExploitingDeposit{}) do Seelies.UnitStartsExploitingDeposit.execute(game, command) end
  def execute(game, command = %Seelies.UnitStopsExploitingDeposit{}) do Seelies.UnitStopsExploitingDeposit.execute(game, command) end
  def execute(game, command = %Seelies.DepositsExploitationTicks{}) do Seelies.DepositsExploitationTicks.execute(game, command) end


  def apply(game, event = %Seelies.GameStarted{}) do Seelies.GameStarted.apply(game, event) end
  def apply(game, event = %Seelies.StartingUnitDeployed{}) do Seelies.StartingUnitDeployed.apply(game, event) end
  def apply(game, event = %Seelies.UnitStartedExploitingDeposit{}) do Seelies.UnitStartedExploitingDeposit.apply(game, event) end
  def apply(game, event = %Seelies.UnitStoppedExploitingDeposit{}) do Seelies.UnitStoppedExploitingDeposit.apply(game, event) end
  def apply(game, event = %Seelies.DepositsExploitationTicked{}) do Seelies.DepositsExploitationTicked.apply(game, event) end


  def resources(game, territory_id) do
    game.territories[territory_id]
  end
end
