defmodule Game do
  defp getShapeScore(shape) do
    case shape do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
  end

  defp getResultScore(result) do
    case result do
      :win -> 6
      :lose -> 0
      :draw -> 3
    end
  end

  def getScore([opponent, mine]) do
    result =
      case {opponent, mine} do
        {:scissors, :rock} -> :win
        {:paper, :scissors} -> :win
        {:rock, :paper} -> :win
        _ -> if opponent === mine, do: :draw, else: :lose
      end

    getShapeScore(mine) + getResultScore(result)
  end

  defp getLosingShape(shape) do
    case shape do
      :rock -> :scissors
      :paper -> :rock
      :scissors -> :paper
    end
  end

  defp getWinningShape(shape) do
    case shape do
      :rock -> :paper
      :paper -> :scissors
      :scissors -> :rock
    end
  end

  def getOtherShape([shape, result]) do
    case result do
      :lose -> getLosingShape(shape)
      :draw -> shape
      :win -> getWinningShape(shape)
    end
  end
end

game =
  File.read!("./data/2.txt")
  |> String.split("\n")
  |> Enum.map(fn row ->
    String.split(row, " ")
    |> Enum.map(fn letter ->
      case letter do
        "A" -> :rock
        "X" -> :rock
        "B" -> :paper
        "Y" -> :paper
        "C" -> :scissors
        "Z" -> :scissors
      end
    end)
  end)

score = game |> Enum.map(&Game.getScore/1) |> Enum.sum()
IO.puts(score)

game2 =
  File.read!("./data/2.txt")
  |> String.split("\n")
  |> Enum.map(fn row ->
    String.split(row, " ")
  end)
  |> Enum.map(fn [opponent, result] ->
    opponent =
      case opponent do
        "A" -> :rock
        "B" -> :paper
        "C" -> :scissors
      end

    result =
      case result do
        "X" -> :lose
        "Y" -> :draw
        "Z" -> :win
      end

    [opponent, Game.getOtherShape([opponent, result])]
  end)

score = game2 |> Enum.map(&Game.getScore/1) |> Enum.sum()
IO.puts(score)
