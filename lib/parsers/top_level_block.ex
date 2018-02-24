defmodule MacroCompiler.Parser.TopLevelBlock do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.Comment

  def parser() do
    many(
      choice([
        ignore(spaces()),
        ignore(newline()),
        ignore(Comment.parser()),

        Macro.parser()
      ])
    )
  end
end
