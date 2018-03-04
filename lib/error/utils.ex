defmodule MacroCompiler.Error.Utils do
  alias MacroCompiler.Parser.Metadata

  def calc_line_and_column(file, %Metadata{line: line, offset: offset}) do
    calc_line_and_column(file, line, offset)
  end

  def calc_line_and_column(file, line, offset) do
    file_lines = file
      |> String.split("\n")

    calc(file_lines, line - 1, offset)
  end

  defp calc(file_lines, line, offset) do
    line_length = file_lines
      |> Enum.at(line)
      |> String.length

    line_length = line_length + 1 # adding + 1 because we need to count the "\n"

    if offset >= line_length do
      calc(file_lines, line + 1, offset - line_length)
    else
      {line + 1, offset}
    end
  end
end
