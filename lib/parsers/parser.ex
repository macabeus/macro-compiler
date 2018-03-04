defmodule MacroCompiler.Parser do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.Metadata

  defmacro parser_command(do: body) do
    quote do
      def parser() do
        map(
          unquote(body),

          fn node ->
            map_command(node)
          end
        )
      end
    end
  end
end
