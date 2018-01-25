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

  def generate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(generate(&1, ast, symbolsTable)))
  end


  def generate(%Macro{name: name, block: block}, ast, symbolsTable) do
    IO.puts "sub macro_#{name} {"

    generate(block, ast, symbolsTable)

    IO.puts "}"
  end

  def generate(%CallExpression{macro: macro, params: params}, _ast, _symbolsTable) do
    params =
      params
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    IO.puts "&macro_#{macro}(#{params});"
  end

  def generate(%DoExpression{action: action}, _ast, _symbolsTable) do
    IO.puts "Commands::run(\"#{action}\");"
  end

  def generate(%LogExpression{message: message}, _ast, _symbolsTable) do
    message =
      message
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

    IO.puts "message \"#{message}\\n\";"
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

  def generate(%ScalarVariableAssignment{scalar_variable: scalar_variable, value: value}, ast, symbolsTable) do
    generate(scalar_variable, ast, symbolsTable)

    IO.puts " = \"#{value}\";"
  end

  def generate(%ArrayVariable{name: name}, _ast, _symbolsTable) do
    IO.puts "@#{name}"
  end

  def generate(%ArrayVariableAssignment{array_variable: array_variable, values: values}, ast, symbolsTable) do
    generate(array_variable, ast, symbolsTable)

    values =
      values
      |> Enum.map(&("\"#{&1}\""))
      |> Enum.join(",")

    IO.puts " = (#{values});"
  end

  def generate(%HashVariable{name: name}, _ast, _symbolsTable) do
    IO.puts "%#{name}"
  end

  def generate(%HashVariableAssignment{hash_variable: hash_variable, keysvalues: keysvalues}, ast, symbolsTable) do
    generate(hash_variable, ast, symbolsTable)

    keysvalues =
      keysvalues
      |> Enum.map(&("\"#{Enum.at(&1, 0)}\" => \"#{Enum.at(&1, 1)}\""))
      |> Enum.join(",")

    IO.puts " = (#{keysvalues});"
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

  def generate(_undefinedNode, _ast, _symbolsTable) do

  end
end
