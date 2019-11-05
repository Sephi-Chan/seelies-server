defmodule Seelies.JsonSerializer do
  alias Commanded.EventStore.TypeProvider
  alias Commanded.Serialization.JsonDecoder

  @doc """
  Serialize given term to JSON binary data.
  """
  def serialize(term) do
    Jason.encode!(term)
  end

  @doc """
  Deserialize given JSON binary data to the expected type.
  """
  def deserialize(binary, config \\ []) do
    {type, opts} =
      case Keyword.get(config, :type) do
        nil -> {nil, %{}}
        type -> {TypeProvider.to_struct(type), %{keys: :strings}}
      end

    binary
    |> Jason.decode!(opts)
    |> keys_to_atoms()
    |> to_struct(type)
    |> JsonDecoder.decode()
  end

  # Convert top level map keys to atoms.
  defp keys_to_atoms(map) when is_map(map) do
    for {key, value} <- map, into: %{} do
      {String.to_atom(key), value}
    end
  end

  defp to_struct(data, nil), do: data
  defp to_struct(data, struct), do: struct(struct, data)
end
