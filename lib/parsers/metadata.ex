defmodule MacroCompiler.Parser.Metadata do
  use Combine
  use Combine.Helpers

  alias Combine.ParserState
  alias MacroCompiler.Parser.Metadata

  @enforce_keys [:line, :offset]
  defstruct [:line, :offset, :ignore]

  defparser getMetadata(%ParserState{status: :ok, line: line, column: col, results: results} = state) do
    case Process.get(:no_metadata) do
      true ->
        %{state | :results => [%Metadata{line: 0, offset: 0} | results]}
      _ ->
        %{state | :results => [%Metadata{line: line, offset: col} | results]}
    end
  end
end
