defmodule Solve.UnlockSafe do
  alias Helpers.UnlockSafe, as: Helpers

  def run do
    {:ok, pid} = Helpers.start_link(initial_pos: 50)

    Helpers.process_instructions(
      pid,
      File.read!("lib/day01/input.txt")
      |> String.split("\n", trim: true)
    )

    # Get counts
    Helpers.counts(pid)

    # iex(1)> Solve.UnlockSafe.run()
    # %{clicks_on_zero: 6671, stops_on_zero: 1152}
    # {part 2 answer, part 1 answer}

    # Inspect per-click events if needed
    # Helpers.events(pid) |> Enum.take(100) |> IO.inspect(label: "first 10 events")
  end
end
