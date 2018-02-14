defmodule MacroCompiler.CodeGeneration do
  alias MacroCompiler.Macro
  alias MacroCompiler.CallExpression
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.UndefScalarVariable
  alias MacroCompiler.ScalarVariableAssignment
  alias MacroCompiler.ArrayVariableAssignment
  alias MacroCompiler.HashVariableAssignment
  alias MacroCompiler.ScalarVariable
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.HashVariable
  alias MacroCompiler.IncrementExpression
  alias MacroCompiler.DecrementExpression
  alias MacroCompiler.PauseExpression
  alias MacroCompiler.PushExpression
  alias MacroCompiler.PopExpression
  alias MacroCompiler.TextValue
  alias MacroCompiler.ShiftExpression
  alias MacroCompiler.UnshiftExpression

  def start_generate(block, ast, symbolsTable) do
    Enum.map(block, &(generate(&1, ast, symbolsTable)))
    |> List.flatten
    |> Enum.map(&IO.puts/1)
  end

  defp generate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(generate(&1, ast, symbolsTable)))
  end


  defp generate(%Macro{name: name, block: block}, ast, symbolsTable) do
    [
      "sub macro_#{name} {",
      generate(block, ast, symbolsTable),
      "}"
    ]
  end

  defp generate(%TextValue{values: values}, ast, symbolsTable) do
    values = values
    |> Enum.map(&(
      case &1 do
        %ScalarVariable{name: _name, array_position: _array_position, hash_position: _hash_position} ->
          generate(&1, ast, symbolsTable)

        %ArrayVariable{name: name} ->
          "\".scalar(@#{name}).\""

        %HashVariable{name: name} ->
          "\".scalar(keys %#{name}).\""

        "\"" ->
          "\\\""

        char ->
          char
      end)
    )
    |> List.to_string

    "\"#{values}\""
  end

  defp generate(%CallExpression{macro: macro, params: params}, _ast, _symbolsTable) do
    params =
      params
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    "&macro_#{macro}(#{params});"
  end

  defp generate(%DoExpression{text: text}, ast, symbolsTable) do
    [
      "Commands::run(",
      generate(text, ast, symbolsTable),
      ");"
    ]
  end

  defp generate(%LogExpression{text: text}, ast, symbolsTable) do
    [
      "message ",
      generate(text, ast, symbolsTable),
      ".\"\\n\";"
    ]
  end

  defp generate(%ScalarVariable{name: name, array_position: array_position, hash_position: hash_position}, _ast, _symbolsTable) do
    case {name, array_position, hash_position} do
      {name, nil, nil} ->
        "$#{name}"

      {name, array_position, nil} ->
        "$#{name}[#{array_position}]"

      {name, nil, hash_position} ->
        "$#{name}{#{hash_position}}"
    end
  end

  defp generate(%ScalarVariableAssignment{scalar_variable: scalar_variable, text: text}, ast, symbolsTable) do
    [
      generate(scalar_variable, ast, symbolsTable),
      " = ",
      generate(text, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%ArrayVariable{name: name}, _ast, _symbolsTable) do
    "@#{name}"
  end

  defp generate(%ArrayVariableAssignment{array_variable: array_variable, texts: texts}, ast, symbolsTable) do
    texts =
      texts
      |> Enum.map(&(generate(&1, ast, symbolsTable)))
      |> Enum.join(",")

    [
      generate(array_variable, ast, symbolsTable),
      " = (#{texts});"
    ]
  end

  defp generate(%HashVariable{name: name}, _ast, _symbolsTable) do
    "%#{name}"
  end

  defp generate(%HashVariableAssignment{hash_variable: hash_variable, keystexts: keystexts}, ast, symbolsTable) do
    keystexts =
      keystexts
      |> Enum.map(&("\"#{Enum.at(&1, 0)}\" => #{generate(Enum.at(&1, 1), ast, symbolsTable)}"))
      |> Enum.join(",")

    [
      generate(hash_variable, ast, symbolsTable),
      " = (#{keystexts});"
    ]
  end

  defp generate(%UndefScalarVariable{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      "undef ",

      generate(scalar_variable, ast, symbolsTable),

      ";"
    ]
  end

  defp generate(%IncrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      generate(scalar_variable, ast, symbolsTable),

      "++;"
    ]
  end

  defp generate(%DecrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      generate(scalar_variable, ast, symbolsTable),

      "--;"
    ]
  end

  defp generate(%PauseExpression{seconds: _seconds}, _ast, _symbolsTable) do
    # TODO
  end

  defp generate(%PushExpression{array_variable: array_variable, text: text}, ast, symbolsTable) do
    [
      "push ",
      generate(array_variable, ast, symbolsTable),
      ",",
      generate(text, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%PopExpression{array_variable: array_variable}, ast, symbolsTable) do
    [
      "pop ",
      generate(array_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%ShiftExpression{array_variable: array_variable}, ast, symbolsTable) do
    [
      "shift ",
      generate(array_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%UnshiftExpression{array_variable: array_variable, text: text}, ast, symbolsTable) do
    [
      "unshift ",
      generate(array_variable, ast, symbolsTable),
      ",",
      generate(text, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(_undefinedNode, _ast, _symbolsTable) do

  end
end
