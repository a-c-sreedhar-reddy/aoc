defmodule Bridge do
  @type direction :: :left | :right | :top | :bottom

  @type point :: {number(), number()}

  @type instruction :: {direction(), number()}

  @type rope :: list(point())

  @spec move_rope(rope(), instruction()) :: {rope(), list(point())}
  def move_rope(rope, {direction, distance}) do
    Enum.reduce(1..distance, {rope, []}, fn _, {rope, tail_positions} ->
      rope = move_rope_unit_distance(rope, direction)
      {rope, [tail_position(rope) | tail_positions]}
    end)
  end

  @spec move_rope_unit_distance(rope(), direction()) :: rope()
  defp move_rope_unit_distance(rope, direction) do
    [{head_x, head_y} | rest] = rope

    new_head =
      case direction do
        :left -> {head_x - 1, head_y}
        :up -> {head_x, head_y + 1}
        :right -> {head_x + 1, head_y}
        :down -> {head_x, head_y - 1}
      end

    new_rope = re_organise_rope([new_head | rest])
    new_rope
  end

  @spec re_organise_rope(rope()) :: rope()
  defp re_organise_rope(rope) do
    position = 1..(length(rope) - 1)

    Enum.reduce_while(position, rope, fn position, rope ->
      prev_knot = Enum.at(rope, position - 1)
      current_knot = Enum.at(rope, position)

      if are_knots_adjacent(prev_knot, current_knot) do
        {:halt, rope}
      else
        new_knot = adjacent_knot_position(prev_knot, current_knot)
        rope = ListUtils.replace_at(rope, position, new_knot)
        {:cont, rope}
      end
    end)
  end

  @spec are_knots_adjacent(point(), point()) :: boolean()
  defp are_knots_adjacent({point_1_x, point_1_y}, point_2) do
    adjacent_points =
      [
        {point_1_x, point_1_y},
        {point_1_x, point_1_y + 1},
        {point_1_x, point_1_y - 1},
        {point_1_x + 1, point_1_y},
        {point_1_x - 1, point_1_y}
      ] ++ diagnol_points({point_1_x, point_1_y})

    adjacent_points |> Enum.any?(fn point -> Tuple.to_list(point) == Tuple.to_list(point_2) end)
  end

  @spec adjacent_knot_position(point(), point()) :: point()
  defp adjacent_knot_position(point_1, point_2) do
    if(knots_same_row?(point_1, point_2)) do
      left? = point_x(point_2) < point_x(point_1)

      if(left?) do
        {point_x(point_2) + 1, point_y(point_2)}
      else
        {point_x(point_2) - 1, point_y(point_2)}
      end
    else
      if knots_same_column?(point_1, point_2) do
        bottom? = point_y(point_2) < point_y(point_1)

        if(bottom?) do
          {point_x(point_2), point_y(point_2) + 1}
        else
          {point_x(point_2), point_y(point_2) - 1}
        end
      else
        diagnol_points = diagnol_points(point_2)

        Enum.find_value(diagnol_points, fn diagnal_point ->
          if(are_knots_adjacent(diagnal_point, point_1)) do
            diagnal_point
          end
        end)
      end
    end
  end

  @spec knots_same_row?(point(), point()) :: boolean()
  defp knots_same_row?({_, point_1_y}, {_, point_2_y}) do
    point_1_y == point_2_y
  end

  @spec knots_same_column?(point(), point()) :: boolean()
  defp knots_same_column?({point_1_x, _}, {point_2_x, _}) do
    point_1_x == point_2_x
  end

  @spec diagnol_points(point()) :: list(point())
  defp diagnol_points(point) do
    x = point_x(point)
    y = point_y(point)
    [{x - 1, y - 1}, {x - 1, y + 1}, {x + 1, y - 1}, {x + 1, y + 1}]
  end

  @spec point_y(point()) :: integer()
  defp point_y({_, value}), do: value

  @spec point_x(point()) :: integer()
  defp point_x({value, _}), do: value

  @spec tail_position(rope()) :: point()
  defp tail_position(rope) do
    Enum.at(rope, length(rope) - 1)
  end
end

defmodule ListUtils do
  def replace_at(list, index, new_value) when index >= 0,
    do: replace_at(list, index, new_value, 0)

  defp replace_at([_ | tail], index, new_value, current_index) when current_index == index,
    do: [new_value | tail]

  defp replace_at([head | tail], index, new_value, current_index) do
    [head | replace_at(tail, index, new_value, current_index + 1)]
  end

  defp replace_at([], _, _, _), do: []
end

defmodule TupleUtils do
  def unique_tuples(list) do
    list
    |> Enum.uniq_by(&to_string_tuple/1)
  end

  defp to_string_tuple({x, y}) do
    "#{x},#{y}"
  end
end

rope = List.duplicate({0, 0}, 10)

{_, tail_positions} =
  File.read!("data/9.txt")
  |> String.split("\n")
  |> Enum.map(fn instruction ->
    case instruction do
      "R " <> number -> {:right, number |> String.to_integer()}
      "L " <> number -> {:left, number |> String.to_integer()}
      "D " <> number -> {:down, number |> String.to_integer()}
      "U " <> number -> {:up, number |> String.to_integer()}
    end
  end)
  |> Enum.reduce({rope, [{0, 0}]}, fn instruction, {rope, tail_positions} ->
    {rope, new_tail_positions} = Bridge.move_rope(rope, instruction)
    {rope, tail_positions ++ new_tail_positions}
  end)

TupleUtils.unique_tuples(tail_positions)
|> length()
|> IO.inspect()
