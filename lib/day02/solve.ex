defmodule Solve.ResolveInvalidIDs do
  require Logger
  alias Helpers.ResolveInvalidIDs, as: Helpers

  def run do
    invalid_ids_map = Helpers.build_invalid_ids_map()

    invalid_ids =
      Helpers.get_chunks()
      |> Task.async_stream(
        fn c ->
          Logger.debug("Loaded #{c}")
          {a, b} = Helpers.parse_for_ab(c)

          Helpers.ab_range(a, b)
          |> Stream.map(&Helpers.evaluate_invalid_ids(&1, invalid_ids_map))
          |> Enum.reject(&is_nil/1)
        end,
        timeout: :infinity
      )
      |> Enum.flat_map(fn {:ok, result} -> result end)

    json = Jason.encode!(invalid_ids)
    File.write!("lib/day02/invalid_ids.json", json)
    %{count: length(invalid_ids), sum: Enum.sum(invalid_ids)}
  end
end
