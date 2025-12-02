defmodule Solve.UnlockSafe do
  alias Helpers.UnlockSafe, as: Helpers

  def run do
    {:ok, pid} = Helpers.start_link(initial_pos: 50)

    Helpers.process_instructions(
      pid,
      File.read!("lib/aoc/1_unlock_safe/input.txt")
      |> String.split("\n", trim: true)
    )

    # Get counts
    Helpers.counts(pid)

    # Inspect per-click events if needed
    # Helpers.events(pid) |> Enum.take(100) |> IO.inspect(label: "first 10 events")
  end
end
