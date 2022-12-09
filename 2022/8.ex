defmodule TreesModule do
  defp is_tree_visible(row, index) do
    {left, [tree | right]} = Enum.split(row, index)

    left |> Enum.all?(fn ctree -> ctree < tree end) ||
      right |> Enum.all?(fn ctree -> ctree < tree end)
  end

  defp get_view_point_row(row, index) do
    {left, [tree | right]} = Enum.split(row, index)
    left = Enum.reverse(left)

    [left_score, right_score] =
      [left, right]
      |> Enum.map(fn row ->
        {score, _} =
          row
          |> List.foldl({0, false}, fn element, {score, found} ->
            if found do
              {score, found}
            else
              {score + 1, element >= tree}
            end
          end)

        score
      end)

    left_score * right_score
  end

  def is_visible(tree, row, col) do
    row_data = Enum.at(tree, row)
    col_data = tree |> Enum.map(fn row -> Enum.at(row, col) end)
    is_tree_visible(row_data, col) || is_tree_visible(col_data, row)
  end

  def get_view_point_score(tree, row, col) do
    row_data = Enum.at(tree, row)
    col_data = tree |> Enum.map(fn row -> Enum.at(row, col) end)
    get_view_point_row(row_data, col) * get_view_point_row(col_data, row)
  end
end

input = File.read!("data/8.txt")

input =
  input
  |> String.split("\n")
  |> Enum.map(fn row ->
    String.graphemes(row)
    |> Enum.map(fn element ->
      String.to_integer(element)
    end)
  end)

input
|> Enum.with_index(fn row, row_index ->
  row
  |> Enum.with_index(fn element, col_index ->
    TreesModule.is_visible(input, row_index, col_index)
  end)
  |> Enum.filter(fn is_visible -> is_visible end)
  |> length()
end)
|> Enum.sum()
|> IO.puts()

input
|> Enum.with_index(fn row, row_index ->
  row
  |> Enum.with_index(fn element, col_index ->
    score = TreesModule.get_view_point_score(input, row_index, col_index)
    score
  end)
  |> List.flatten()
end)
|> List.flatten()
|> Enum.max()
|> IO.puts()
