defmodule MacroCompiler.Parser.ArrayVariable do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name]
  defstruct [:name]

  parser_command do
    sequence([
      ignore(string("@")),
      Identifier.parser()
    ])
  end

  def map_command([name]) do
    %ArrayVariable{name: name}
  end
end
