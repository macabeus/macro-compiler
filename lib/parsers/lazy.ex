defmodule MacroCompiler.Parser.Lazy do
  use Combine
  use Combine.Helpers

  alias Combine.ParserState

  defparser lazy_parser(%ParserState{status: :ok} = state, generator) do
    (generator.()).(state)
  end

  defmacro lazy(body) do
    quote do
      lazy_parser(fn -> unquote(body) end)
    end
  end
end
