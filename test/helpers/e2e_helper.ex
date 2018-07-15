defmodule MacroCompiler.Test.Helper.E2e do
  def compiler_and_run_macro(macro_name, event_macro_code) do
    File.write!("test/e2e/perl/codes/#{macro_name}.txt", event_macro_code)

    perl_code =
      MacroCompiler.compiler("test/e2e/perl/codes/#{macro_name}.txt")
      |> Enum.join("\n")
    File.write!("test/e2e/perl/codes/#{macro_name}.pl", perl_code)

    {output, 0} = System.cmd("perl", ["runner.pl", macro_name], cd: "test/e2e/perl/")

    output
    |> String.split("\n")
  end

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import MacroCompiler.Test.Helper.E2e

      @output_index 0

      setup_all do
        file_name = __MODULE__ |> to_string() |> String.split(".") |> List.last
        perl_outputs = MacroCompiler.Test.Helper.E2e.compiler_and_run_macro(file_name, code())
        {:ok, %{perl_outputs: perl_outputs}}
      end
    end
  end

  defmacro test_output(type, desc, assertion) do
    quote do
      test unquote(desc), %{perl_outputs: perl_outputs} do
        type = unquote(type)
        assertion = unquote(assertion)

        output = Enum.at(perl_outputs, @output_index)

        output_casted =
          case type do
            :string ->
              output
            :integer ->
              {value, _} = Integer.parse(output)
              value
          end

        assert assertion.(output_casted)
      end

      @output_index @output_index + 1
    end
  end
end

