input = File.read!("data/7.txt")

defmodule Systems do
  def cd_command?(command) do
    String.starts_with?(command, "$ cd ")
  end

  def dir_command?(command) do
    String.starts_with?(command, "dir")
  end

  def add_file_to_file_system(fs, path, file_name, size) do
    case path do
      [] ->
        [{"file", file_name, size} | fs]

      [first_path | remaining_path] ->
        has_directory =
          fs
          |> Enum.find(fn file_or_dir ->
            case file_or_dir do
              {"dir", ^first_path, _} -> true
              _ -> false
            end
          end)

        fs =
          if has_directory,
            do: fs,
            else: [{"dir", first_path, []} | fs]

        fs
        |> Enum.map(fn file_or_dir ->
          case file_or_dir do
            {"dir", ^first_path, first_path_directory} ->
              {"dir", first_path,
               add_file_to_file_system(first_path_directory, remaining_path, file_name, size)}

            _ ->
              file_or_dir
          end
        end)
    end
  end

  def get_directory_size(fs) do
    sub_dir_sizes =
      fs
      |> Enum.filter(fn file_or_dir ->
        case file_or_dir do
          {"dir", _, _} -> true
          _ -> false
        end
      end)
      |> Enum.map(fn {"dir", _, fs} -> get_directory_size(fs) end)

    file_sizes =
      fs
      |> Enum.map(fn file_or_dir ->
        case file_or_dir do
          {"file", _, size} -> size
          _ -> 0
        end
      end)

    dir_size = Enum.sum(sub_dir_sizes ++ file_sizes)

    dir_size
  end

  def get_all_directories_sizes(fs) do
    sub_dir_size =
      fs
      |> Enum.filter(fn file_or_dir ->
        case file_or_dir do
          {"dir", _, _} -> true
          _ -> false
        end
      end)
      |> Enum.map(fn {"dir", _, fs} -> get_directory_size(fs) end)
      |> Enum.sum()

    file_size =
      fs
      |> Enum.map(fn file_or_dir ->
        case file_or_dir do
          {"file", _, size} -> size
          _ -> 0
        end
      end)
      |> Enum.sum()

    [
      sub_dir_size + file_size
      | fs
        |> Enum.filter(fn file_or_dir ->
          case file_or_dir do
            {"dir", _, _} -> true
            _ -> false
          end
        end)
        |> Enum.flat_map(fn {"dir", _, fs} -> get_all_directories_sizes(fs) end)
    ]
  end
end

{fs, _} =
  input
  |> String.split("\n")
  |> List.foldl({[], []}, fn command, {fs, current_dir} ->
    if Systems.cd_command?(command) do
      [_, _, dir] = command |> String.split(" ")

      case dir do
        "/" -> {fs, []}
        ".." -> {fs, tl(current_dir)}
        _ -> {fs, [dir | current_dir]}
      end
    else
      if command == "$ ls" || Systems.dir_command?(command) do
        {fs, current_dir}
      else
        [size, file_name] = String.split(command, " ")
        {size, _} = Integer.parse(size)
        fs = Systems.add_file_to_file_system(fs, Enum.reverse(current_dir), file_name, size)
        {fs, current_dir}
      end
    end
  end)

dir_sizes =
  fs
  |> Systems.get_all_directories_sizes()

dir_sizes
|> Enum.filter(fn a -> a <= 100_000 end)
|> Enum.sum()
|> IO.puts()

root_size = Systems.get_directory_size(fs)
free_space = 70_000_000 - root_size
required_space = 30_000_000 - free_space
dir_sizes |> Enum.sort() |> Enum.find(fn size -> size >= required_space end) |> IO.puts()
