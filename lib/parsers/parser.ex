defmodule MacroCompiler.Parser do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.Metadata

  defmacro parser_command(do: body) do
    quote do
      def parser() do
        map(
          sequence([
            Metadata.getMetadata(),
            unquote(body)
          ]),

          fn [metadata, node] ->
            {
              map_command(node),
              metadata
            }
          end
        )
      end
    end
  end
end
