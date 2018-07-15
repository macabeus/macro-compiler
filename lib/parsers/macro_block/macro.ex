defmodule MacroCompiler.Parser.Macro do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.MacroBlock
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name, :block]
  defstruct [:name, :block]

  parser_command do
    sequence([
      ignore(string("macro")),
      ignore(spaces()),

      Identifier.parser(),

      ignore(spaces()),
      ignore(char("{")),
      skip(newline()),

      MacroBlock.parser(),

      skip(char("}"))
    ])
  end

  def map_command([macro_name, block]) do
    %Macro{name: macro_name, block: block}
  end
end
