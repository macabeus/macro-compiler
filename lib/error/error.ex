defmodule MacroCompiler.Error do
  import MacroCompiler.Error.Utils

  alias MacroCompiler.Parser.SyntaxError
  alias MacroCompiler.SemanticAnalysis.FatalError, as: FatalSemanticError

  defp puts_stderr(message), do: IO.puts(:stderr, message)

  ###
  # Compiler-time error message
  def show(file, %SyntaxError{message: message, line: line, offset: offset}) do
    {line, col} = calc_line_and_column(file, line, offset)

    puts_stderr IO.ANSI.format([:red, :bright, "#{message}\n"])

    file
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.filter(fn {_, index} ->
      index >= line - 2 and index <= line + 2
    end)
    |> Enum.map(fn {lineText, index} ->
      if index == line do
        lineTextSliced0 = String.slice(lineText, 0..(col-1))
        lineTextSliced1 = String.slice(lineText, col..String.length(lineText))

        IO.ANSI.format([:bright, "#{index}  -  ", lineTextSliced0, :red,  lineTextSliced1], true)
      else
        "#{index}  -  #{lineText}"
      end
    end)
    |> Enum.each(&puts_stderr/1)

    puts_stderr "\n\nMacro couldn't be compiled. Sorry"
  end

  ###
  # Semantic analysis error message
  def show(file, validates_result) do
    validates_result
    |> sort_validates_result
    |> Enum.map(fn %{type: type, message: message, metadatas: metadatas} ->
      format_message(file, type, message, metadatas)
      |> IO.ANSI.format
    end)
    |> Enum.each(&puts_stderr/1)
  end

  defp sort_validates_result(validates_result) do
    priorities = %{error: 0, warning: 1}

    Enum.sort(validates_result, fn (%{type: type_a}, %{type: type_b}) ->
      Map.get(priorities, type_a) < Map.get(priorities, type_b)
    end)
  end

  defp format_message(file, type, message, metadatas) do
    prefix = case type do
      :warning ->
        IO.ANSI.format([:yellow, :bright, "Warning: "])

      :error ->
        IO.ANSI.format([:yellow, :bright, "FATAL ERROR: "])
    end

    [prefix | message] ++ " #{metadates_to_line_column_message(file, metadatas)}"
  end

  def raise_fatal_error(validates_result) do
    if has_fatal_error?(validates_result) do
      raise FatalSemanticError, message: "Could not be compiled because some fatal error happened"
    end
  end

  defp has_fatal_error?(validates_result) do
    Enum.any?(validates_result, fn %{type: type} ->
      type == :error
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
