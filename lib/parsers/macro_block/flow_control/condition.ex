defmodule MacroCompiler.Parser.Condition do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.Condition
  alias MacroCompiler.Parser.ScalarValue

  @enforce_keys [:scalar_variable, :operator, :value]
  defstruct [:scalar_variable, :operator, :value]

  parser_command do
    sequence([
      ScalarValue.parser(),

      skip(spaces()),
      choice([
        string(">="),
        string(">"),
        string("=="),
        string("="),
        string("<="),
        string("<"),
        string("!=")
      ]),
      skip(spaces()),

      ScalarValue.parser()
    ])
  end

  def map_command([scalar_variable, operator, value]) do
    %Condition{scalar_variable: scalar_variable, operator: operator, value: value}
  end
end

