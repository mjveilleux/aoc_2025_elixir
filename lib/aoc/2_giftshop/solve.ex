defmodule Solve.ResolveInvalidIDs do
  require Logger
  alias Helpers.ResolveInvalidIDs, as: Helpers

  def run do
    invalid_ids =
      Helpers.get_chunks()
      |> Task.async_stream(
        fn c ->
          Logger.debug("Loaded #{c}")
          {a, b} = Helpers.parse_for_ab(c)
          raw_list = Helpers.ab_range(a, b)
          list_of_candidates = Helpers.find_potential_candidates(raw_list)

          list_of_candidates
          |> Enum.map(&Helpers.evaluate_invalid_ids/1)
          |> Enum.reject(&is_nil/1)
        end,
        timeout: :infinity
      )
      |> Enum.flat_map(fn {:ok, result} -> result end)

    json = Jason.encode!(invalid_ids)
    File.write!("lib/aoc/2_giftshop/invalid_ids.json", json)
    %{count: length(invalid_ids), sum: Enum.sum(invalid_ids)}
  end
end
