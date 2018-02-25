defmodule MacroCompiler.ShowErrors do
  alias MacroCompiler.Parser.SyntaxError

  def show(file, %SyntaxError{message: message, line: line, offset: offset}) do
    {line, col} = calc_line_and_column(file, line, offset)

    IO.puts IO.ANSI.format([:red, :bright, "#{message}\n"])

    file
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.filter(fn {_, index} ->
      index >= line - 2 and index <= line + 2
    end)
    |> Enum.each(fn {lineText, index} ->
      if index == line do
        lineTextSliced0 = String.slice(lineText, 0..(col-1))
        lineTextSliced1 = String.slice(lineText, col..String.length(lineText))

        IO.puts IO.ANSI.format([:bright, "#{index}  -  ", lineTextSliced0, :red,  lineTextSliced1], true)
      else
        IO.puts "#{index}  -  #{lineText}"
      end
    end)

    IO.puts "\n\nMacro couldn't be compiled. Sorry"
  end

  defp calc_line_and_column(file, line, offset) do
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
