defmodule MacroCompiler.CodeGeneration do
  alias MacroCompiler.Macro
  alias MacroCompiler.CallExpression
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression

  def generate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(generate(&1, ast, symbolsTable)))
  end


  def generate(%Macro{name: name, block: block}, ast, symbolsTable) do
    IO.puts "sub macro_#{name} {"

    generate(block, ast, symbolsTable)

    IO.puts "}"
  end

  def generate(%CallExpression{macro: macro, params: params}, _ast, _symbolsTable) do
    IO.puts "&macro_#{macro};"
  end

  def generate(%DoExpression{action: action}, _ast, _symbolsTable) do
    IO.puts "Commands::run(\"#{action}\");"
  end

  def generate(%LogExpression{message: message}, _ast, _symbolsTable) do
    IO.puts "message \"#{message}\\n\";"
  end

  def generate(_undefinedNode, _ast, _symbolsTable) do

  end
end
