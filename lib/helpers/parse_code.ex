defmodule ParseCode do
  @moduledoc """
  - Loads a source code FILE
  - Cleans it by removing spaces and carriage returns
  - joins them
  """

  defp load_file_stream(file) do
    file |> File.stream!([:read, :utf8, :trim_bom], :line)
  end

  def parse_stream(file) do
    file
    |> load_file_stream
    |> Stream.map(&(&1 |> String.trim
    |> String.replace(~r/\s*\n+\s*/, " ")
    |> String.replace(~r/\s/," ") 
    |> String.codepoints))
    |> Enum.reduce([], &(&2 ++ &1))
  end

end
