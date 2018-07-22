defmodule MacroCompiler.Test.E2e.CLICommand do
  use MacroCompiler.Test.Helper.E2e, %{
    run_test_macro: false,
    run_cli_command: "ManualCallingMacro"
  }

  def code, do: """
    macro ManualCallingMacro {
      log called!
    }
  """

  test_output :string, "should called ManualCallingMacro", fn value ->
    value == "called!"
  end
end

