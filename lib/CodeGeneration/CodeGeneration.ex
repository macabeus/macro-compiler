defmodule MacroCompiler.CodeGeneration do
  alias MacroCompiler.Macro
  alias MacroCompiler.CallExpression
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.ScalarVariableAssignment

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
    IO.puts "message \"#{message}\\n\";"
  end

  def generate(%ScalarVariableAssignment{name: name, value: value}, _ast, _symbolsTable) do
    IO.puts "$#{name} = \"#{value}\";"
  end

  def generate(_undefinedNode, _ast, _symbolsTable) do

  end
end
