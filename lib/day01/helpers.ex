defmodule Helpers.UnlockSafe do
  use GenServer

  @moduledoc """
  Per-click dial simulator with event logging.

  Each event: %{seq: integer, new_pos: 0..99, is_stopped: 0|1}
  - seq: monotonically increasing event sequence
  - new_pos: position after this click
  - is_stopped: 1 when this click is the last of an instruction
  """

  # Public API

  def start_link(opts \\ []) do
    initial_pos = Keyword.get(opts, :initial_pos, 50)
    max_events = Keyword.get(opts, :max_events, :infinity)
    GenServer.start_link(__MODULE__, {initial_pos, max_events}, name: Keyword.get(opts, :name))
  end

  def process_instructions(pid, instructions) when is_list(instructions) do
    GenServer.cast(pid, {:instructions, instructions})
  end

  def process_instruction(pid, instruction) when is_binary(instruction) do
    GenServer.cast(pid, {:instruction, instruction})
  end

  def counts(pid) do
    GenServer.call(pid, :counts)
  end

  def events(pid) do
    GenServer.call(pid, :events)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  # Server

  @impl true
  def init({initial_pos, max_events}) do
    {:ok,
     %{
       pos: Integer.mod(initial_pos, 100),
       seq: 0,
       events: [],
       clicks_on_zero: 0,
       stops_on_zero: 0,
       max_events: max_events
     }}
  end

  @impl true
  def handle_cast({:instructions, list}, state) do
    new_state =
      Enum.reduce(list, state, fn instr, acc ->
        do_process_instruction(acc, instr)
      end)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:instruction, instr}, state) do
    {:noreply, do_process_instruction(state, instr)}
  end

  @impl true
  def handle_call(:counts, _from, state) do
    {:reply,
     %{
       clicks_on_zero: state.clicks_on_zero,
       stops_on_zero: state.stops_on_zero
     }, state}
  end

  @impl true
  def handle_call(:events, _from, state) do
    {:reply, Enum.reverse(state.events), state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Helpers

  defp do_process_instruction(state, instruction) do
    {dir, amt} = parse_instruction!(instruction)
    clicks = clicks_sequence(state.pos, dir, amt)

    Enum.with_index(clicks, 1)
    |> Enum.reduce(state, fn {new_pos, idx}, acc ->
      is_stopped = if idx == length(clicks), do: 1, else: 0
      log_event(acc, new_pos, is_stopped)
    end)
  end

  defp parse_instruction!(<<dir::binary-size(1), rest::binary>>) when dir in ["L", "R"] do
    {dir, String.to_integer(rest)}
  end

  defp parse_instruction!(_bad),
    do: raise(ArgumentError, "Instruction must look like \"L10\" or \"R200\"")

  # Produce the per-click new positions from a start pos
  # Example: clicks_sequence(50, "L", 3) -> [49, 48, 47]
  # Example: clicks_sequence(99, "R", 2) -> [0, 1]
  defp clicks_sequence(start_pos, "R", amount) when amount >= 0 do
    for step <- 1..amount do
      Integer.mod(start_pos + step, 100)
    end
  end

  defp clicks_sequence(start_pos, "L", amount) when amount >= 0 do
    for step <- 1..amount do
      Integer.mod(start_pos - step, 100)
    end
  end

  defp log_event(state, new_pos, is_stopped) do
    seq = state.seq + 1

    clicks_on_zero = state.clicks_on_zero + if new_pos == 0, do: 1, else: 0
    stops_on_zero = state.stops_on_zero + if new_pos == 0 and is_stopped == 1, do: 1, else: 0

    event = %{seq: seq, new_pos: new_pos, is_stopped: is_stopped}

    events =
      case state.max_events do
        :infinity ->
          [event | state.events]

        max when is_integer(max) and max > 0 ->
          # keep a bounded list by dropping oldest when exceeding max
          trimmed = [event | state.events]

          if length(trimmed) > max do
            Enum.take(trimmed, max)
          else
            trimmed
          end
      end

    %{
      state
      | pos: new_pos,
        seq: seq,
        events: events,
        clicks_on_zero: clicks_on_zero,
        stops_on_zero: stops_on_zero
    }
  end
end
