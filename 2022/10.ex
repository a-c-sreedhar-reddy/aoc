defmodule Device do
  @type instruction :: {:addx, integer()} | {:noop}
  @spec signal_strengths(list(instruction())) :: %{
          required(integer()) => integer()
        }
  def signal_strengths(instructions) do
    instructions
    |> Enum.reduce(%{cycle: 1, strength: 0, register_value: 1}, fn instruction,
                                                                   %{
                                                                     cycle: cycle,
                                                                     strength: strength,
                                                                     register_value:
                                                                       register_value
                                                                   } ->
      measure_current_cycle? = measure_cycle?(cycle)
      measure_next_cycle? = measure_cycle?(cycle + 1)

      case instruction do
        {:noop} ->
          %{
            cycle: cycle + 1,
            register_value: register_value,
            strength:
              if measure_current_cycle? do
                strength + cycle * register_value
              else
                strength
              end
          }

        {:addx, value} ->
          # 1st cycle
          %{cycle: cycle, register_value: register_value, strength: strength} = %{
            cycle: cycle + 1,
            register_value: register_value,
            strength:
              if measure_current_cycle? do
                strength + cycle * register_value
              else
                strength
              end
          }

          # 2nd cycle
          %{
            cycle: cycle + 1,
            register_value: register_value + value,
            strength:
              if measure_next_cycle? do
                strength + cycle * register_value
              else
                strength
              end
          }
      end
    end)
  end

  @spec get_display(list(instruction())) :: String.t()
  def get_display(instructions) do
    instructions
    |> Enum.reduce(%{display: "", register_value: 1, cycle: 1}, fn instruction,
                                                                   %{
                                                                     display: display,
                                                                     register_value:
                                                                       register_value,
                                                                     cycle: cycle
                                                                   } ->
      case instruction do
        {:noop} ->
          %{
            display: update_display(display, register_value, cycle),
            register_value: register_value,
            cycle: cycle + 1
          }

        {:addx, value} ->
          # 1st cycle
          %{cycle: cycle, register_value: register_value, display: display} = %{
            display: update_display(display, register_value, cycle),
            cycle: cycle + 1,
            register_value: register_value
          }

          # 2nd cycle
          %{
            display: update_display(display, register_value, cycle),
            cycle: cycle + 1,
            register_value: register_value + value
          }
      end
    end)
  end

  @spec update_display(String.t(), integer(), integer()) :: String.t()
  defp update_display(display, register_value, cycle) do
    display_lit? = display_lit?(register_value, cycle)
    display = if display_lit?, do: "#{display}#", else: "#{display}."
    if rem(cycle, 40) == 0, do: "#{display}\n", else: display
  end

  @spec measure_cycle?(integer()) :: boolean()
  defp measure_cycle?(cycle) do
    cycle >= 20 && (cycle == 20 || rem(cycle - 20, 40) == 0)
  end

  @spec display_lit?(integer(), integer()) :: boolean()
  defp display_lit?(register_value, cycle) do
    left_edge? = rem(register_value, 40) == 0
    right_edge? = rem(register_value + 1, 40) == 0

    sprite_pixels = [
      if(left_edge?, do: nil, else: register_value - 1),
      register_value,
      if(right_edge?, do: nil, else: register_value + 1)
    ]

    current_pixel = rem(cycle - 1, 40)

    sprite_pixels |> Enum.member?(current_pixel)
  end
end

instructions =
  File.read!("data/10.txt")
  |> String.split("\n")
  |> Enum.map(fn instruction ->
    case instruction do
      "addx " <> value -> {:addx, String.to_integer(value)}
      "noop" -> {:noop}
    end
  end)

Device.signal_strengths(instructions) |> IO.inspect()
Device.get_display(instructions).display |> String.split("\n") |> IO.inspect()
