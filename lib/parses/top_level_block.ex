defmodule MacroCompiler.TopLevelBlock do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.Macro

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
