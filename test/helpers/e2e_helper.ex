defmodule MacroCompiler.Test.Helper.E2e do
  def compiler_and_run_macro(macro_name, event_macro_code, run_test_macro, run_cli_command) do
    File.write!("test/e2e/perl/codes/#{macro_name}.txt", event_macro_code)

    perl_code =
      MacroCompiler.compiler("test/e2e/perl/codes/#{macro_name}.txt")
      |> Enum.join("\n")
    File.write!("test/e2e/perl/codes/#{macro_name}.pl", perl_code)

    run_test_macro_perl_bool = case run_test_macro do
      true -> "1"
      false -> "0"
    end

    {output, 0} = System.cmd("perl", ["runner.pl", macro_name, run_test_macro_perl_bool, run_cli_command], cd: "test/e2e/perl/")

    output
    |> String.split("\n")
  end

  defmacro __using__(opts) do
    options = case opts do
      {_, _, keyword_list} ->
        Enum.into(keyword_list, %{})
      _ ->
        %{}
    end

    run_test_macro = case options do
      %{run_test_macro: value} -> value
      _ -> true
    end

    run_cli_command = case options do
      %{run_cli_command: value} -> value
      _ -> ""
    end

    quote do
      use ExUnit.Case, async: true
      import MacroCompiler.Test.Helper.E2e

      @output_index 0

      setup_all do
        file_name = __MODULE__ |> to_string() |> String.split(".") |> List.last
        perl_outputs =
          MacroCompiler.Test.Helper.E2e.compiler_and_run_macro(file_name, code(), unquote(run_test_macro), unquote(run_cli_command))
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

