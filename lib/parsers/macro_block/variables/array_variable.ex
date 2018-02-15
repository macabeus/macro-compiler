defmodule MacroCompiler.Parser.ArrayVariable do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name]
  defstruct [:name]

  def parser() do
    map(
      sequence([
        ignore(string("@")),
        Identifier.parser()
      ]),
      fn [name] -> %ArrayVariable{name: name} end
    )
  end
end
