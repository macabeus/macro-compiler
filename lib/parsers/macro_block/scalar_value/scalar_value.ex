defmodule MacroCompiler.Parser.ScalarValue do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser.Lazy

  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.TextValue
  alias MacroCompiler.Parser.ScalarVariable

  def parser() do
    choice([
      lazy(ScalarVariable.parser()),
      lazy(RandCommand.parser()),
      lazy(TextValue.parser())
    ])
  end
end
