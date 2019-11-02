defmodule Seelies.Species do
  def decode(species) when is_atom(species), do: species
  def decode(species), do: String.to_existing_atom(species)
end
