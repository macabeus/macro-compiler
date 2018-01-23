defmodule MacroCompiler.Macro do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.MacroBlock
  alias MacroCompiler.Identifier

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
      fn [macro_name, block] -> %MacroCompiler.Macro{name: macro_name, block: block} end
    )
  end
end
