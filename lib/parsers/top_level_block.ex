defmodule MacroCompiler.Parser.TopLevelBlock do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.Macro

  def parser() do
    many(
      choice([
        ignore(spaces()),
        ignore(newline()),

        Macro.parser()
      ])
    )
  end
end
