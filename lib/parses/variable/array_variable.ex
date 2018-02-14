defmodule MacroCompiler.ArrayVariable do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.Identifier

  @enforce_keys [:name]
  defstruct [:name]

  def parser() do
    map(
      sequence([
        ignore(string("@")),
        Identifier.parser()
      ]),
      fn [name] -> %MacroCompiler.ArrayVariable{name: name} end
    )
  end
end
