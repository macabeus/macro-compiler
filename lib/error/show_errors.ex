defmodule MacroCompiler.Error.ShowErrors do
  import MacroCompiler.Error.Utils

  alias MacroCompiler.Parser.SyntaxError

  ###
  # Compiler-time error message
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

  ###
  # Semantic analysis error message
  def show(file, validates_result) do
    warning_message_prefix = IO.ANSI.format([:yellow, :bright, "Warning: "])

    validates_result
    |> Enum.each(&case &1 do
      %{type: :warning, message: message, metadatas: metadatas} ->
        [warning_message_prefix | message] ++ " #{metadates_to_line_column_message(file, metadatas)}"
        |> IO.ANSI.format
        |> IO.puts
    end)
  end

  defp metadates_to_line_column_message(file, metadatas) do
    occurrences =
      metadatas
      |> Enum.map(&calc_line_and_column(file, &1))
      |> Enum.reverse

    occurrences_text =
      occurrences
      |> Enum.map(fn {line, column} -> "#{line}:#{column}" end)
      |> Enum.join(" and ")

    "It's happened at #{occurrences_text}"
  end
end
