defmodule Helpers.Batteries do

  def get_input_lines do
    File.read!("lib/day03/input.txt")
    |> String.split("\n", trim: true)
  end

end
