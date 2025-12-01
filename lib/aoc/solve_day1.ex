defmodule Aoc2025Elixir.Aoc do
  def initialize_lock do
    sequence = Enum.to_list(0..99)
    concatenated_sequence = Enum.concat(List.duplicate(sequence, 10000))
    Enum.with_index(concatenated_sequence, fn value, index -> {index, value} end)
  end

  def find_middle_50_of_lock_sequence do
    lock = initialize_lock()
    fifties = Enum.filter(lock, fn {_, val} -> val == 50 end)

    case length(fifties) do
      0 ->
        nil

      len ->
        middle_index = div(len - 1, 2)
        {pos, _} = Enum.at(fifties, middle_index)
        pos
    end
  end

  # we will call movements clicks
  def clicks_to_take do
    # get the file documents/day1.txt 
    # read line by line 
    # if starts with R then positive 
    # if starts with L then negative

    read_file = File.read!("lib/aoc/documents/day1.txt")

    # return list of lines 

    read_file
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      num = String.slice(line, 1..-1//1) |> String.to_integer()

      case String.at(line, 0) do
        "R" -> num
        "L" -> -num
      end
    end)
  end

  def table_of_movements do
    lock = initialize_lock()
    clicks = clicks_to_take()
    start_pos = find_middle_50_of_lock_sequence()

    # Optimization: accessing a large list by index is slow (O(n)). 
    # Converting to map makes access O(log n) or O(1).
    pos_to_val = Map.new(lock)
    max_pos = length(lock) - 1

    # FIX 1: map_reduce returns {list, accumulator}
    {movements, _final_pos} =
      Enum.map_reduce(Enum.with_index(clicks), start_pos, fn {delta, step}, cur_pos ->
        new_pos = cur_pos + delta

        if new_pos < 0 or new_pos > max_pos do
          raise ArgumentError,
                "out of bounds at step #{step}: new_pos=#{new_pos}, bounds=0..#{max_pos}"
        end

        value_at_new = Map.fetch!(pos_to_val, new_pos)

        movement = %{
          step: step,
          from_pos: cur_pos,
          to_pos: new_pos,
          # This is the lock value (0..99)
          to_value: value_at_new,
          delta: delta
        }

        {movement, new_pos}
      end)

    movements
  end

  def count_zeroes_in_movements_table do
    table = table_of_movements()

    # FIX 2: Pattern match on the Map, not a Tuple
    Enum.count(table, fn %{to_value: val} -> val == 0 end)
  end
end

defmodule Aoc2025Elixir.SolveDay1 do
  def run do
    # get all 50s in this lock
    # Aoc2025Elixir.Aoc.initialize_lock()
    # Aoc2025Elixir.Aoc.find_middle_50_of_lock_sequence()
    # Aoc2025Elixir.Aoc.find_middle_50_of_lock_sequence()
    # Aoc2025Elixir.Aoc.get_and_transcribe_documents()
    # Aoc2025Elixir.Aoc.get_final_position_and_lock_value()
    # Aoc2025Elixir.Aoc.table_of_movements()
    Aoc2025Elixir.Aoc.count_zeroes_in_movements_table()
  end
end
