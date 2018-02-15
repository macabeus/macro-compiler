defmodule MacroCompiler.Parser.Macro do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.MacroBlock
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name, :block]
  defstruct [:name, :block]

  def parser() do
    map(
      sequence([
        ignore(string("macro")),
        ignore(spaces()),

        Identifier.parser(),

        ignore(spaces()),
        ignore(char("{")),
        skip(newline()),

        MacroBlock.parser(),

        ignore(char("}"))
      ]),
      fn [macro_name, block] -> %Macro{name: macro_name, block: block} end
    )
  end
end
