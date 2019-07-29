defmodule Seelies.Unit do
  @resources_per_minute %{
    ant:    %{ gold: 10, silver: 10 },
    beetle: %{ gold: 10, silver: 10 },
    wasp:   %{ gold: 10, silver: 10 }
  }


  def resources_per_second(species, resource_type) do
    @resources_per_minute[species][resource_type]/60
  end
end
