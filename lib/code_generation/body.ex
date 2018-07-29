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
  alias MacroCompiler.Parser.PostfixIf
  alias MacroCompiler.Parser.Condition
  alias MacroCompiler.Parser.SingleCheck
  alias MacroCompiler.Parser.IfBlock

  def start_generate(block) do
    Enum.map(block, &(generate(&1)))
    |> List.flatten
  end

  defp generate({_node, %{ignore: true}}) do

  end

  defp generate({node, _metadata}) do
    generate(node)
  end

  defp generate(block) when is_list(block) do
    Enum.map(block, &(generate(&1)))
  end


  defp generate(%Macro{name: name, block: block}) do
    [
      "sub macro_#{name} {",
      generate(block),
      "}"
    ]
  end

  defp generate(%TextValue{values: values}) do
    values = values
    |> Enum.map(&(
      case &1 do
        {%ScalarVariable{array_position: nil}, _metadata} ->
          generate(&1)

        {%ScalarVariable{array_position: _array_position}, _metadata} ->
          [
            "\".",
            generate(&1),
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

  defp generate(%CallCommand{macro: macro, params: params}) do
    params =
      params
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    "&macro_#{macro}(#{params});"
  end

  defp generate(%DoCommand{text: text}) do
    [
      "Commands::run(",
      generate(text),
      ");"
    ]
  end

  defp generate(%LogCommand{text: text}) do
    [
      "message ",
      generate(text),
      ".\"\\n\";"
    ]
  end

  defp generate(%ScalarVariable{name: ".zeny"}) do
    "$char->{zeny}"
  end

  defp generate(%ScalarVariable{name: name, array_position: array_position, hash_position: hash_position}) do
    case {name, array_position, hash_position} do
      {name, nil, nil} ->
        "$#{name}"

      {name, array_position, nil} ->
        [
          "$#{name}[",
          generate(array_position),
          "]"
        ]

      {name, nil, hash_position} ->
        "$#{name}{#{hash_position}}"
    end
  end

  defp generate(%ScalarAssignmentCommand{scalar_variable: scalar_variable, scalar_value: scalar_value}) do
    [
      generate(scalar_variable),
      " = ",
      generate(scalar_value),
      ";"
    ]
  end

  defp generate(%ArrayVariable{name: name}) do
    "@#{name}"
  end

  defp generate(%ArrayAssignmentCommand{array_variable: array_variable, texts: texts}) do
    texts =
      texts
      |> Enum.map(&(generate(&1)))
      |> Enum.join(",")

    [
      generate(array_variable),
      " = (#{texts});"
    ]
  end

  defp generate(%HashVariable{name: name}) do
    "%#{name}"
  end

  defp generate(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: keystexts}) do
    keystexts =
      keystexts
      |> Enum.map(&("\"#{Enum.at(&1, 0)}\" => #{generate(Enum.at(&1, 1))}"))
      |> Enum.join(",")

    [
      generate(hash_variable),
      " = (#{keystexts});"
    ]
  end

  defp generate(%DeleteCommand{scalar_variable: scalar_variable}) do
    [
      "delete ",
      generate(scalar_variable),
      ";"
    ]
  end

  defp generate(%KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}) do
    [
      generate(array_variable),
      "= keys ",
      generate(param_hash_variable),
      ";"
    ]
  end

  defp generate(%ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}) do
    [
      generate(array_variable),
      "= values ",
      generate(param_hash_variable),
      ";"
    ]
  end

  defp generate(%UndefCommand{scalar_variable: scalar_variable}) do
    [
      "undef ",

      generate(scalar_variable),

      ";"
    ]
  end

  defp generate(%IncrementCommand{scalar_variable: scalar_variable}) do
    [
      generate(scalar_variable),

      "++;"
    ]
  end

  defp generate(%DecrementCommand{scalar_variable: scalar_variable}) do
    [
      generate(scalar_variable),

      "--;"
    ]
  end

  defp generate(%PauseCommand{seconds: _seconds}) do
    # TODO
  end

  defp generate(%PushCommand{array_variable: array_variable, text: text}) do
    [
      "push ",
      generate(array_variable),
      ",",
      generate(text),
      ";"
    ]
  end

  defp generate(%PopCommand{array_variable: array_variable}) do
    [
      "pop ",
      generate(array_variable),
      ";"
    ]
  end

  defp generate(%ShiftCommand{array_variable: array_variable}) do
    [
      "shift ",
      generate(array_variable),
      ";"
    ]
  end

  defp generate(%UnshiftCommand{array_variable: array_variable, text: text}) do
    [
      "unshift ",
      generate(array_variable),
      ",",
      generate(text),
      ";"
    ]
  end

  defp generate(%RandCommand{min: min, max: max}) do
    [
      "(",
      generate(min),
      " + int(rand(1 + ",
      generate(max),
      " - ",
      generate(min),
      ")))"
    ]
  end

  defp generate(%RandomCommand{values: values}) do
    valuesMapped =
      values
      |> Enum.map(&generate(&1))
      |> Enum.join(",")

    [
      "((",
      valuesMapped,
      ")[int (rand #{length(values)})])"
    ]
  end

  defp generate(%PostfixIf{condition: condition, block: block}) do
    [
      "if (",
      generate(condition),
      ") {",
      generate(block),
      "}"
    ]
  end

  defp generate(%Condition{scalar_variable: scalar_variable, operator: operator, value: value}) do
    [
      generate(scalar_variable),
      operator,
      generate(value)
    ]
  end

  defp generate(%SingleCheck{scalar_variable: scalar_variable}) do
    [
      generate(scalar_variable)
    ]
  end

  defp generate(%IfBlock{condition: condition, block: block}) do
    [
      "if (",
      generate(condition),
      ") {",
      generate(block),
      "}"
    ]
  end

  defp generate(_undefinedNode) do

  end
end
