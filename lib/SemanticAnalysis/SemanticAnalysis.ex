defmodule MacroCompiler.SemanticAnalysis do
  alias MacroCompiler.Macro
  alias MacroCompiler.CallExpression
  alias MacroCompiler.MacroSymbolsTable
  alias MacroCompiler.SemanticAnalysisError

  def validate(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(validate(&1, ast, symbolsTable)))
  end


  def validate(%Macro{name: _name, block: block}, ast, symbolsTable) do
    validate(block, ast, symbolsTable)
  end

  def validate(%CallExpression{macro: macro, params: _params}, _ast, symbolsTable) do
    macroNameExists = Enum.find(
      symbolsTable,
      fn %MacroSymbolsTable{name: ^macro} -> true; _ -> false end
    )

    if macroNameExists == nil do
      raise SemanticAnalysisError,
        message: "'call' expression invalid: macro '#{macro}' doesn't exits!"
    end
  end

  def validate(_undefinedNode, _ast, _symbolsTable) do

  end
end
