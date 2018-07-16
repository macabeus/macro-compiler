defmodule MacroCompiler.Parser.SingleCheck do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.SingleCheck
  alias MacroCompiler.Parser.ScalarValue

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  parser_command do
    ScalarValue.parser()
  end

  def map_command(scalar_variable) do
    %SingleCheck{scalar_variable: scalar_variable}
  end
end

