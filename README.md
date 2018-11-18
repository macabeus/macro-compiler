<img src="https://raw.githubusercontent.com/macabeus/macro-compiler/master/docs/logo-small.png" align="right" />

# MacroCompiler
> The best way to create macros.

[![Build Status](https://travis-ci.com/macabeus/macro-compiler.svg?branch=master)](https://travis-ci.com/macabeus/macro-compiler)

MacroCompiler compiles [EventMacro](http://openkore.com/index.php/EventMacro) to a [OpenKore](https://github.com/OpenKore/openkore/) plugin (that is, Perl). EventMacro is a language to automate the actions from OpenKore – the bot used in the Rangarok online game. It compiles to Perl since OpenKore itself is written in Perl.

You may use EventMacro to configure the bot to complete quests or to buy itens, for example. Currently the only solution to run EventMacro on OpenKore is using a regex-based interpreter, which is a bad solution. This project aims to offer a faster, more reliable and flexible alternative to run macros on OpenKore.

**Faster** because the OpenKore doesn't need to interpret a Macro code to run Perl code. Now it runs Perl code directly and the compiler can optimize the EventMacro.
**More reliable** because the compiler shows errors and you are able to fix them before actually running the bot.
**More flexible** because it is easier to add new features in a compiler than in a regex-based interpreter.

>Hey! Warning: This project is under construction, thus it is incomplete and currently only has a tiny subset of EventMacro commands.

# Example

The macro

```
macro goToRandomCity {
  @cities = (prontera, payon, geffen, morroc)
  $randomCity = $cities[&rand(0, 3)]
 
  log I'll go to $randomCity !
  do move $randomCity
}
```

will compile to

```
package macroCompiled;
use Log qw(message);
my $randomCity;
my @cities;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_goToRandomCity {
  @cities = ("prontera","payon","geffen","morroc");
  $randomCity = $cities[("0" + int(rand(1 + "3" - "0")))];
  message "I'll go to $randomCity !"."\n";
  Commands::run("move $randomCity");
}

```

Then you could use this plugin. [You may see more examples here.](docs/examples.md)

# How to run

You must have Elixir in your computer. [Read how to install Elixir here](https://elixir-lang.org/install.html).

Run the command below so you can compile your macro:

```
mix run lib/macrocompiler.ex path/of/eventMacro.txt > macro.pl
````

# Test

```
mix test
```

# How does it work?

Since this is a project for studying purposes, I will explain how I created it, including its logic and design. Also, you can see [this asciinema](https://asciinema.org/a/199032) about how to add a new command at the compiler, step by step - this video has just 4 minutes!

## Talks

As a part of my study, I presented some talks about compilers and I used this project as a study case.

- Talk in English at The Conf 2018 🇬🇧 [Slides](https://speakerdeck.com/macabeus/demystifying-compilers-by-writing-your-own)

<a href="https://www.youtube.com/watch?v=zMJYoYwOCd4"><img src="https://img.youtube.com/vi/zMJYoYwOCd4/hqdefault.jpg" /></a>

- Talk in Portuguese at Pagar.me 🇧🇷 [Slides Part 1](https://speakerdeck.com/macabeus/aprendendo-compiladores-fazendo-um-parte-1) and [Slides Part 2](https://speakerdeck.com/macabeus/aprendendo-compiladores-fazendo-um-parte-2)

<a href="https://www.youtube.com/watch?v=t77ThZNCJGY"><img src="http://img.youtube.com/vi/t77ThZNCJGY/0.jpg" /></a>

## Language design

I **have not** designed EventMacro: its specs have been already made by other people and my compiler only needs to keep interoperability. A few important things that have influenced EventMacro design are:

- Perl inspiration; given the fact that OpenKore is written in Perl and many people who work on OpenKore project also write macros;
- The syntax was designed in order to make it easy to write a regexp-based interpreter;
- It was designed aiming to ease non-programmers' learning process.

> Designing a programming language and a compiler are processes that have very different focuses, but many tasks in common. [You may read more about it here.](https://www.quora.com/Which-is-the-difference-between-design-a-programming-language-and-design-a-compiler/answer/Quildreen-Motta)

## Parser

I decided to write the parser using a parser combinator-based strategy because Elixir already has an awesome library for doing so: [Combine](https://github.com/bitwalker/combine). In this phase, the parser maps the source code on a representation called AST - Abstract Syntax Tree. We only have this intermediary representation through the whole compiler.

An advantage of parser combinator is that we get the AST directly, but a disadvantage is that we will have poor error messages.

On my compiler, each node on the AST is a tuple with two elements, where the first element is the struct representing the mapped code and the second one is its metadata. The metadata is important to return a meaningful error message on the next phases (e.g. to tell the coder the line and column where the error happened). Another situation where the metadata is important is on the optimization phase - I will provide more details about it bellow.

## Semantic analysis

The AST built on the previous phase is passed to the semantic analyzer. It builds a data structure called symbol table, which describes the names used on the code (function and variable names, for example). We could describe the arity of a function, for example.

The aim of semantic analysis is to check whether the code is semantically valid or not, and it uses the symbol table to do so. For example, it checks if there are any variables that are being used but which have never been written.

## Optimization

The optimizer uses both the AST and the symbol table in order to create an equivalent AST, but that results in a faster and smaller code. For example, an optimization implemented in MacroCompiler is [dead code elimination](https://en.wikipedia.org/wiki/Dead_code_elimination). A variable that is written but never called is useless so the optimizer finds these situations and tells the node's metadata to ignore or completely remove this node on code generation phase.

## Code generation

Using the AST, we could map it to another language. In our context, an OpenKore plugin - that is, a Perl code. Since the EventMacro language and Perl are very similar, it's easy to do this mapping.

We have two phases of code generation: header and body. On the header we find global requirements to declare on top of file - for example, variables declarations, because on EventMacro all variables are globals–but the same doesn't happen on Perl. On the body we generate the code itself.
