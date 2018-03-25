defmodule MacroCompiler.Parser.ScalarValue do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser.Lazy

  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.RandomCommand
  alias MacroCompiler.Parser.TextValue

  def parser() do
    choice([
      lazy(ScalarVariable.parser()),
      lazy(RandCommand.parser()),
      lazy(RandomCommand.parser()),
      lazy(TextValue.parser())
    ])
  end
end
