# Command-Line Calculator - OCaml
This is a very simple command-line calculator that evaluates expressions, programmed in OCaml.

## Usage
```
>>> 6 + 7
13.

>>> 6.9 * -(7/3 + 2)
-29.9
```

(`>>>` denotes user input.)

### Verbose output
To see the output of both the tokeniser and parser, run the app with `True` as the first argument:

```
>>> 6.9 * -(7/3 + 2)
=== Tokens ===
[(Tokenizer.Token.Number 6.9);
  (Tokenizer.Token.Operator Tokenizer.Token.Asterisk);
  (Tokenizer.Token.Operator Tokenizer.Token.Minus);
  Tokenizer.Token.ParenthesisOpen; (Tokenizer.Token.Number 7.);
  (Tokenizer.Token.Operator Tokenizer.Token.Slash);
  (Tokenizer.Token.Number 3.);
  (Tokenizer.Token.Operator Tokenizer.Token.Plus);
  (Tokenizer.Token.Number 2.); Tokenizer.Token.ParenthesisClose]

=== Abstract Syntax Tree ===
(Parser.Expression.BinaryOp ((Parser.Expression.Number 6.9),
   Parser.Expression.Multiply,
   (Parser.Expression.UnaryOp (Parser.Expression.Negative,
      (Parser.Expression.BinaryOp (
         (Parser.Expression.BinaryOp ((Parser.Expression.Number 7.),
            Parser.Expression.Divide, (Parser.Expression.Number 3.))),
         Parser.Expression.Add, (Parser.Expression.Number 2.)))
      ))
   ))

=== Result ===
-29.9
```

## Features
For my own sanity, this is extremely limited, so the only supported operations are:
- Addition (a + b)
- Subtraction (a - b)
- Multiplication (a * b)
- Division (a / b)

Additonally, negative numbers can be expressed (-a), and sub-expressions can be wrapped in parentheses.

This should all follow the rules of [PEDMAS](https://en.wikipedia.org/wiki/Order_of_operations). If you notice anything outputting something it shouldn't, please open an [issue](https://github.com/KojoBailey/command-line-calculator-ocaml/issues)!

You should also get errors if you try doing anything invalid, such as `5 +- 2 *` or dividing by zero. If you are able to get something to successfully evaluate that doesn't make sense, please also open an issue!

## Motivation
Interesed in the implementation of tooling (compilers, interpreters) for programming languages, I figured that trying to implement a simple CLI calculator would be a good start.

I've already implemented a [similar project in Haskell](https://github.com/KojoBailey/cli-calculator-hs), and I then decided to learn some OCaml and see what all the hype's about via this implementation.

Later, I plan to also do a similar project in Rust, although with many more features since I want to consider Rust as my "main" language going forward, replacing C++ - that is, until an even nicer language comes around.
