defmodule MacroCompiler.CodeGeneration do
  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.CallCommand
  alias MacroCompiler.Parser.DoCommand
  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.UndefCommand
  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ArrayAssignmentCommand
  alias MacroCompiler.Parser.HashAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.IncrementCommand
  alias MacroCompiler.Parser.DecrementCommand
  alias MacroCompiler.Parser.PauseCommand
  alias MacroCompiler.Parser.PushCommand
  alias MacroCompiler.Parser.PopCommand
  alias MacroCompiler.Parser.TextValue
  alias MacroCompiler.Parser.ShiftCommand
  alias MacroCompiler.Parser.UnshiftCommand
  alias MacroCompiler.Parser.DeleteCommand
  alias MacroCompiler.Parser.KeysCommand
  alias MacroCompiler.Parser.ValuesCommand

  def start_generate(block, ast, symbolsTable) do
    Enum.map(block, &(generate(&1, ast, symbolsTable)))
    |> List.flatten
    |> Enum.map(&IO.puts/1)
  end

  defp generate({_node, %{ignore: true}}, ast, symbolsTable) do

  end

  defp generate({node, _metadata}, ast, symbolsTable) do
    generate(node, ast, symbolsTable)
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
        {%ScalarVariable{name: _name, array_position: _array_position, hash_position: _hash_position}, _metadata} ->
          generate(&1, ast, symbolsTable)

        {%ArrayVariable{name: name}, _metadata} ->
          "\".scalar(@#{name}).\""

        {%HashVariable{name: name}, _metadata} ->
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

  defp generate(%CallCommand{macro: macro, params: params}, _ast, _symbolsTable) do
    params =
      params
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    "&macro_#{macro}(#{params});"
  end

  defp generate(%DoCommand{text: text}, ast, symbolsTable) do
    [
      "Commands::run(",
      generate(text, ast, symbolsTable),
      ");"
    ]
  end

  defp generate(%LogCommand{text: text}, ast, symbolsTable) do
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

  defp generate(%ScalarAssignmentCommand{scalar_variable: scalar_variable, text: text}, ast, symbolsTable) do
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

  defp generate(%ArrayAssignmentCommand{array_variable: array_variable, texts: texts}, ast, symbolsTable) do
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

  defp generate(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: keystexts}, ast, symbolsTable) do
    keystexts =
      keystexts
      |> Enum.map(&("\"#{Enum.at(&1, 0)}\" => #{generate(Enum.at(&1, 1), ast, symbolsTable)}"))
      |> Enum.join(",")

    [
      generate(hash_variable, ast, symbolsTable),
      " = (#{keystexts});"
    ]
  end

  defp generate(%DeleteCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      "delete ",
      generate(scalar_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, ast, symbolsTable) do
    [
      generate(array_variable, ast, symbolsTable),
      "= keys ",
      generate(param_hash_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, ast, symbolsTable) do
    [
      generate(array_variable, ast, symbolsTable),
      "= values ",
      generate(param_hash_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%UndefCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      "undef ",

      generate(scalar_variable, ast, symbolsTable),

      ";"
    ]
  end

  defp generate(%IncrementCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      generate(scalar_variable, ast, symbolsTable),

      "++;"
    ]
  end

  defp generate(%DecrementCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    [
      generate(scalar_variable, ast, symbolsTable),

      "--;"
    ]
  end

  defp generate(%PauseCommand{seconds: _seconds}, _ast, _symbolsTable) do
    # TODO
  end

  defp generate(%PushCommand{array_variable: array_variable, text: text}, ast, symbolsTable) do
    [
      "push ",
      generate(array_variable, ast, symbolsTable),
      ",",
      generate(text, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%PopCommand{array_variable: array_variable}, ast, symbolsTable) do
    [
      "pop ",
      generate(array_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%ShiftCommand{array_variable: array_variable}, ast, symbolsTable) do
    [
      "shift ",
      generate(array_variable, ast, symbolsTable),
      ";"
    ]
  end

  defp generate(%UnshiftCommand{array_variable: array_variable, text: text}, ast, symbolsTable) do
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
