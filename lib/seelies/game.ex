defmodule Seelies.Game do
  defstruct [:game_id, :board, :units, :exploitations, :territories, :convoys, :teams, :players]


  def execute(game, command = %Seelies.StartGame{}) do Seelies.StartGame.execute(game, command) end
  def execute(game, command = %Seelies.StopGame{}) do Seelies.StopGame.execute(game, command) end
  def execute(game, command = %Seelies.DeployStartingUnit{}) do Seelies.DeployStartingUnit.execute(game, command) end
  def execute(game, command = %Seelies.UnitStartsExploitingDeposit{}) do Seelies.UnitStartsExploitingDeposit.execute(game, command) end
  def execute(game, command = %Seelies.UnitStopsExploitingDeposit{}) do Seelies.UnitStopsExploitingDeposit.execute(game, command) end
  def execute(game, command = %Seelies.DepositsExploitationTicks{}) do Seelies.DepositsExploitationTicks.execute(game, command) end
  def execute(game, command = %Seelies.PrepareConvoy{}) do Seelies.PrepareConvoy.execute(game, command) end
  def execute(game, command = %Seelies.UnitJoinsConvoy{}) do Seelies.UnitJoinsConvoy.execute(game, command) end
  def execute(game, command = %Seelies.UnitLeavesConvoy{}) do Seelies.UnitLeavesConvoy.execute(game, command) end
  def execute(game, command = %Seelies.AddResources{}) do Seelies.AddResources.execute(game, command) end
  def execute(game, command = %Seelies.LoadResourcesIntoConvoy{}) do Seelies.LoadResourcesIntoConvoy.execute(game, command) end
  def execute(game, command = %Seelies.UnloadResourcesFromConvoy{}) do Seelies.UnloadResourcesFromConvoy.execute(game, command) end
  def execute(game, command = %Seelies.ConvoyStarts{}) do Seelies.ConvoyStarts.execute(game, command) end
  def execute(game, command = %Seelies.ConvoyReachesDestination{}) do Seelies.ConvoyReachesDestination.execute(game, command) end
  def execute(game, command = %Seelies.DisbandConvoy{}) do Seelies.DisbandConvoy.execute(game, command) end
  def execute(game, command = %Seelies.PlanBait{}) do Seelies.PlanBait.execute(game, command) end
  def execute(game, command = %Seelies.RemoveBait{}) do Seelies.RemoveBait.execute(game, command) end
  def execute(game, command = %Seelies.StartUnitTraining{}) do Seelies.StartUnitTraining.execute(game, command) end
  def execute(game, command = %Seelies.SpawnUnit{}) do Seelies.SpawnUnit.execute(game, command) end


  def apply(game, event = %Seelies.GameStarted{}) do Seelies.GameStarted.apply(game, event) end
  def apply(game, event = %Seelies.GameStopped{}) do Seelies.GameStopped.apply(game, event) end
  def apply(game, event = %Seelies.StartingUnitDeployed{}) do Seelies.StartingUnitDeployed.apply(game, event) end
  def apply(game, event = %Seelies.UnitStartedExploitingDeposit{}) do Seelies.UnitStartedExploitingDeposit.apply(game, event) end
  def apply(game, event = %Seelies.UnitStoppedExploitingDeposit{}) do Seelies.UnitStoppedExploitingDeposit.apply(game, event) end
  def apply(game, event = %Seelies.DepositsExploitationTicked{}) do Seelies.DepositsExploitationTicked.apply(game, event) end
  def apply(game, event = %Seelies.ConvoyReadied{}) do Seelies.ConvoyReadied.apply(game, event) end
  def apply(game, event = %Seelies.UnitJoinedConvoy{}) do Seelies.UnitJoinedConvoy.apply(game, event) end
  def apply(game, event = %Seelies.UnitLeftConvoy{}) do Seelies.UnitLeftConvoy.apply(game, event) end
  def apply(game, event = %Seelies.ResourcesAdded{}) do Seelies.ResourcesAdded.apply(game, event) end
  def apply(game, event = %Seelies.ResourcesLoadedIntoConvoy{}) do Seelies.ResourcesLoadedIntoConvoy.apply(game, event) end
  def apply(game, event = %Seelies.ResourcesUnloadedFromConvoy{}) do Seelies.ResourcesUnloadedFromConvoy.apply(game, event) end
  def apply(game, event = %Seelies.ConvoyStarted{}) do Seelies.ConvoyStarted.apply(game, event) end
  def apply(game, event = %Seelies.ConvoyReachedDestination{}) do Seelies.ConvoyReachedDestination.apply(game, event) end
  def apply(game, event = %Seelies.ConvoyDisbanded{}) do Seelies.ConvoyDisbanded.apply(game, event) end
  def apply(game, event = %Seelies.BaitPlanned{}) do Seelies.BaitPlanned.apply(game, event) end
  def apply(game, event = %Seelies.BaitRemoved{}) do Seelies.BaitRemoved.apply(game, event) end
  def apply(game, event = %Seelies.UnitTrainingStarted{}) do Seelies.UnitTrainingStarted.apply(game, event) end
  def apply(game, event = %Seelies.UnitSpawned{}) do Seelies.UnitSpawned.apply(game, event) end
end


defmodule Seelies.GameLifespan do
  def after_event(%Seelies.GameStopped{}), do: :stop
  def after_event(_event), do: :infinity
  def after_command(_command), do: :infinity
  def after_error(_error), do: :infinity
end
