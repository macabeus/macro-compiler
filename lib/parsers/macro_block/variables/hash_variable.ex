defmodule MacroCompiler.Parser.HashVariable do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name]
  defstruct [:name]

  parser_command do
    sequence([
      ignore(string("%")),
      Identifier.parser()
    ])
  end

  def map_command([name]) do
    %HashVariable{name: name}
  end
end
