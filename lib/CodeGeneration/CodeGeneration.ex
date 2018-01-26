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

  def generate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(generate(&1, ast, symbolsTable)))
  end


  def generate(%Macro{name: name, block: block}, ast, symbolsTable) do
    IO.puts "sub macro_#{name} {"

    generate(block, ast, symbolsTable)

    IO.puts "}"
  end

  def generate(%TextValue{values: values}, _ast, _symbolsTable) do
    values = values
    |> Enum.map(&(
      case &1 do
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

  def generate(%CallExpression{macro: macro, params: params}, _ast, _symbolsTable) do
    params =
      params
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    IO.puts "&macro_#{macro}(#{params});"
  end

  def generate(%DoExpression{text: text}, ast, symbolsTable) do
    IO.puts "Commands::run(#{generate(text, ast, symbolsTable)});"
  end

  def generate(%LogExpression{text: text}, ast, symbolsTable) do
    IO.puts "message #{generate(text, ast, symbolsTable)}.\"\\n\";"
  end

  def generate(%ScalarVariable{name: name, array_position: array_position, hash_position: hash_position}, _ast, _symbolsTable) do
    case {name, array_position, hash_position} do
      {name, nil, nil} ->
        IO.puts "$#{name}"

      {name, array_position, nil} ->
        IO.puts "$#{name}[#{array_position}]"

      {name, nil, hash_position} ->
        IO.puts "$#{name}{#{hash_position}}"
    end
  end

  def generate(%ScalarVariableAssignment{scalar_variable: scalar_variable, text: text}, ast, symbolsTable) do
    generate(scalar_variable, ast, symbolsTable)

    IO.puts " = #{generate(text, ast, symbolsTable)};"
  end

  def generate(%ArrayVariable{name: name}, _ast, _symbolsTable) do
    IO.puts "@#{name}"
  end

  def generate(%ArrayVariableAssignment{array_variable: array_variable, texts: texts}, ast, symbolsTable) do
    generate(array_variable, ast, symbolsTable)

    texts =
      texts
      |> Enum.map(&(generate(&1, ast, symbolsTable)))
      |> Enum.join(",")

    IO.puts " = (#{texts});"
  end

  def generate(%HashVariable{name: name}, _ast, _symbolsTable) do
    IO.puts "%#{name}"
  end

  def generate(%HashVariableAssignment{hash_variable: hash_variable, keystexts: keystexts}, ast, symbolsTable) do
    generate(hash_variable, ast, symbolsTable)

    keystexts =
      keystexts
      |> Enum.map(&("\"#{Enum.at(&1, 0)}\" => #{generate(Enum.at(&1, 1), ast, symbolsTable)}"))
      |> Enum.join(",")

    IO.puts " = (#{keystexts});"
  end

  def generate(%UndefScalarVariable{scalar_variable: scalar_variable}, ast, symbolsTable) do
    IO.puts "undef "

    generate(scalar_variable, ast, symbolsTable)

    IO.puts ";"
  end

  def generate(%IncrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    generate(scalar_variable, ast, symbolsTable)

    IO.puts "++;"
  end

  def generate(%DecrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    generate(scalar_variable, ast, symbolsTable)

    IO.puts "--;"
  end

  def generate(%PauseExpression{seconds: _seconds}, _ast, _symbolsTable) do
    # TODO
  end

  def generate(%PushExpression{array_variable: array_variable, text: text}, ast, symbolsTable) do
    IO.puts "push "
    generate(array_variable, ast, symbolsTable)
    IO.puts(",")
    IO.puts(generate(text, ast, symbolsTable))
    IO.puts(";")
  end

  def generate(%PopExpression{array_variable: array_variable}, ast, symbolsTable) do
    IO.puts "pop "
    generate(array_variable, ast, symbolsTable)
    IO.puts(";")
  end

  def generate(%ShiftExpression{array_variable: array_variable}, ast, symbolsTable) do
    IO.puts "shift "
    generate(array_variable, ast, symbolsTable)
    IO.puts(";")
  end

  def generate(%UnshiftExpression{array_variable: array_variable, text: text}, ast, symbolsTable) do
    IO.puts "unshift "
    generate(array_variable, ast, symbolsTable)
    IO.puts(",")
    IO.puts(generate(text, ast, symbolsTable))
    IO.puts(";")
  end

  def generate(_undefinedNode, _ast, _symbolsTable) do

  end
end
