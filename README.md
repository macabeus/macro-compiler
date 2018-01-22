<h1 align="center"> MacroCompiler </h1> <br>
<p align="center">
  <a href="">
    <img alt="Logo" src="https://i.imgur.com/QeSM2Ca.png" width="108">
  </a>
</p>

>The best way to create macros.

MacroCompiler compiles from the awesome [EventMacro](http://openkore.com/index.php/EventMacro) to [OpenKore](https://github.com/OpenKore/openkore/) plugin (that is, Perl).

This project aims to offer a faster, more secure and more flexible alternative to run macros on OpenKore.

**Faster** because the OpenKore doesn't need to interpret a Macro code to then run Perl code. Now it runs Perl code directly.
**More secure** because the compiler shows errors, then you can fix them before running the bot.
**More flexible** because it's easier to add new features in a compiler than a regex-based interpreter.

>Hey! Warning: This project is under construction, then it's incomplete and it only has a tiny subset of EventMacro commands.

# Example

The macro

```
macro save {
  $map = prontera
  do move $map 151 29
  do talknpc 151 29 c r0
  call sayHello
}

macro sayHello {
  do c hello to everyone!
}
```

will compile to

```
package macroCompiled;
use Commands;
my $map;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_save {
$map = "prontera";
Commands::run("move $map 151 29");
Commands::run("talknpc 151 29 c r0");
&macro_sayHello();
}
sub macro_sayHello {
Commands::run("c hello to everyone!");
}
```

Then you could use this plugin.

# How to run

You must have Elixir in your computer. [You could read here how to install it](https://elixir-lang.org/install.html).

To compile your macro, you need to run this command:

```
mix run lib/macrocompiler.ex path/of/eventMacro.txt > macro.pl
```
