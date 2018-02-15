defmodule MacroCompiler.MacroSymbolsTable do
  alias MacroCompiler.Parser.Macro

  @enforce_keys [:name]
  defstruct [:name]

  def build(%Macro{name: name, block: _block}) do
    %MacroCompiler.MacroSymbolsTable{name: name}
  end
end
