defmodule MacroCompiler.Parser.HashVariable do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name]
  defstruct [:name]

  def parser() do
    map(
      sequence([
        ignore(string("%")),
        Identifier.parser()
      ]),
      fn [name] -> %HashVariable{name: name} end
    )
  end
end
