defmodule MacroCompiler.CodeGeneration.Body do
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
  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.RandomCommand

  def start_generate(block, symbolsTable) do
    Enum.map(block, &(generate(&1, symbolsTable)))
    |> List.flatten
  end

  defp generate({_node, %{ignore: true}}, symbolsTable) do

  end

  defp generate({node, _metadata}, symbolsTable) do
    generate(node, symbolsTable)
  end

  defp generate(block, symbolsTable) when is_list(block) do
    Enum.map(block, &(generate(&1, symbolsTable)))
  end


  defp generate(%Macro{name: name, block: block}, symbolsTable) do
    [
      "sub macro_#{name} {",
      generate(block, symbolsTable),
      "}"
    ]
  end

  defp generate(%TextValue{values: values}, symbolsTable) do
    values = values
    |> Enum.map(&(
      case &1 do
        {%ScalarVariable{array_position: nil}, _metadata} ->
          generate(&1, symbolsTable)

        {%ScalarVariable{array_position: array_position}, _metadata} ->
          [
            "\".",
            generate(&1, symbolsTable),
            ".\""
          ]

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

  defp generate(%CallCommand{macro: macro, params: params}, _symbolsTable) do
    params =
      params
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    "&macro_#{macro}(#{params});"
  end

  defp generate(%DoCommand{text: text}, symbolsTable) do
    [
      "Commands::run(",
      generate(text, symbolsTable),
      ");"
    ]
  end

  defp generate(%LogCommand{text: text}, symbolsTable) do
    [
      "message ",
      generate(text, symbolsTable),
      ".\"\\n\";"
    ]
  end

  defp generate(%ScalarVariable{name: name, array_position: array_position, hash_position: hash_position}, symbolsTable) do
    case {name, array_position, hash_position} do
      {name, nil, nil} ->
        "$#{name}"

      {name, array_position, nil} ->
        [
          "$#{name}[",
          generate(array_position, symbolsTable),
          "]"
        ]

      {name, nil, hash_position} ->
        "$#{name}{#{hash_position}}"
    end
  end

  defp generate(%ScalarAssignmentCommand{scalar_variable: scalar_variable, scalar_value: scalar_value}, symbolsTable) do
    [
      generate(scalar_variable, symbolsTable),
      " = ",
      generate(scalar_value, symbolsTable),
      ";"
    ]
  end

  defp generate(%ArrayVariable{name: name}, _symbolsTable) do
    "@#{name}"
  end

  defp generate(%ArrayAssignmentCommand{array_variable: array_variable, texts: texts}, symbolsTable) do
    texts =
      texts
      |> Enum.map(&(generate(&1, symbolsTable)))
      |> Enum.join(",")

    [
      generate(array_variable, symbolsTable),
      " = (#{texts});"
    ]
  end

  defp generate(%HashVariable{name: name}, _symbolsTable) do
    "%#{name}"
  end

  defp generate(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: keystexts}, symbolsTable) do
    keystexts =
      keystexts
      |> Enum.map(&("\"#{Enum.at(&1, 0)}\" => #{generate(Enum.at(&1, 1), symbolsTable)}"))
      |> Enum.join(",")

    [
      generate(hash_variable, symbolsTable),
      " = (#{keystexts});"
    ]
  end

  defp generate(%DeleteCommand{scalar_variable: scalar_variable}, symbolsTable) do
    [
      "delete ",
      generate(scalar_variable, symbolsTable),
      ";"
    ]
  end

  defp generate(%KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, symbolsTable) do
    [
      generate(array_variable, symbolsTable),
      "= keys ",
      generate(param_hash_variable, symbolsTable),
      ";"
    ]
  end

  defp generate(%ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, symbolsTable) do
    [
      generate(array_variable, symbolsTable),
      "= values ",
      generate(param_hash_variable, symbolsTable),
      ";"
    ]
  end

  defp generate(%UndefCommand{scalar_variable: scalar_variable}, symbolsTable) do
    [
      "undef ",

      generate(scalar_variable, symbolsTable),

      ";"
    ]
  end

  defp generate(%IncrementCommand{scalar_variable: scalar_variable}, symbolsTable) do
    [
      generate(scalar_variable, symbolsTable),

      "++;"
    ]
  end

  defp generate(%DecrementCommand{scalar_variable: scalar_variable}, symbolsTable) do
    [
      generate(scalar_variable, symbolsTable),

      "--;"
    ]
  end

  defp generate(%PauseCommand{seconds: _seconds}, _symbolsTable) do
    # TODO
  end

  defp generate(%PushCommand{array_variable: array_variable, text: text}, symbolsTable) do
    [
      "push ",
      generate(array_variable, symbolsTable),
      ",",
      generate(text, symbolsTable),
      ";"
    ]
  end

  defp generate(%PopCommand{array_variable: array_variable}, symbolsTable) do
    [
      "pop ",
      generate(array_variable, symbolsTable),
      ";"
    ]
  end

  defp generate(%ShiftCommand{array_variable: array_variable}, symbolsTable) do
    [
      "shift ",
      generate(array_variable, symbolsTable),
      ";"
    ]
  end

  defp generate(%UnshiftCommand{array_variable: array_variable, text: text}, symbolsTable) do
    [
      "unshift ",
      generate(array_variable, symbolsTable),
      ",",
      generate(text, symbolsTable),
      ";"
    ]
  end

  defp generate(%RandCommand{min: min, max: max}, symbolsTable) do
    [
      "(",
      generate(min, symbolsTable),
      " + int(rand(1 + ",
      generate(max, symbolsTable),
      " - ",
      generate(min, symbolsTable),
      ")))"
    ]
  end

  defp generate(%RandomCommand{values: values}, symbolsTable) do
    valuesMapped =
      values
      |> Enum.map(&generate(&1, symbolsTable))
      |> Enum.join(",")

    [
      "((",
      valuesMapped,
      ")[int (rand #{length(values)})])"
    ]
  end

  defp generate(_undefinedNode, _symbolsTable) do

  end
end
