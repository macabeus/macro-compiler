defmodule MacroCompiler.Parser.IfBlock do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser
  import MacroCompiler.Parser.Lazy

  alias MacroCompiler.Parser.IfBlock
  alias MacroCompiler.Parser.SingleCheck
  alias MacroCompiler.Parser.Condition
  alias MacroCompiler.Parser.MacroBlock

  @enforce_keys [:condition, :block]
  defstruct [:condition, :block]

  parser_command do
    sequence([
      ignore(string("if (")),

      choice([
        Condition.parser(),
        SingleCheck.parser()
      ]),

      ignore(string(")")),
      skip(spaces()),

      ignore(string("{")),
      skip(newline()),

      lazy(MacroBlock.parser()),

      skip(char("}"))
    ])
  end

  def map_command([condition, block]) do
    %IfBlock{condition: condition, block: block}
  end
end

