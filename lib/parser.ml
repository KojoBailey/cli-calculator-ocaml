module Expression = struct
  type bin_op =
  | Add
  | Subtract
  | Multiply
  | Divide
  | Exponentiate
  | Equals
  | GreaterThan
  | LessThan
  | GreaterOrEqual
  | LessOrEqual
  | And
  | Or
  | Xor
  [@@deriving show]

  type un_op =
  | Negative
  | Percentage
  | Factorialize
  | Not
  [@@deriving show]

  type t =
  | BinaryOp of t * bin_op * t
  | UnaryOp of un_op * t
  | Number of float
  | Variable of int
  [@@deriving show]
end

let ( let* ) = Result.bind

type parse_result = (Expression.t * Tokenizer.Token.t list, string) result

(* LAYER 4 - Parentheses, Negatives, Boolean Not, Variables, Numbers *)
let rec parse_l4 : Tokenizer.Token.t list -> parse_result = function
  | ParenthesisOpen :: tokens ->
    let* (expr, rest) = parse_l0 tokens in
    begin match rest with
    | ParenthesisClose :: rest' -> Ok (expr, rest')
    | _ -> Error "Missing closing parenthesis."
    end
  | Number n :: tokens -> Ok (Number n, tokens)
  | Identifier id :: tokens ->
    if Hashtbl.mem Variables.variable_handles id then
      let handle = Hashtbl.find Variables.variable_handles id in
      Ok (Variable handle, tokens)
    else Error ("Undefined variable: " ^ id)
  | Operator Minus :: tokens ->
    let* (expr, rest) = parse_l3 tokens in
    Ok (Expression.UnaryOp (Negative, expr), rest)
  | Keyword Not :: tokens ->
    let* (expr, rest) = parse_l3 tokens in
    Ok (Expression.UnaryOp (Not, expr), rest)
  | [] -> Error "Unexpected end of expression."
  | t :: _ -> Error ("Unexpected token: " ^ [%show: Tokenizer.Token.t] t)

(* LAYER 3 - Exponentiation, Percentage, Factorial *)
and parse_l3_rest : Expression.t * Tokenizer.Token.t list -> parse_result = function
  | (left, Operator Caret :: tokens) ->
    let* (expr, rest) = parse_l4 tokens in
    parse_l3_rest (Expression.BinaryOp (left, Exponentiate, expr), rest)
  | (left, Operator Percent :: tokens) ->
    parse_l3_rest (Expression.UnaryOp (Percentage, left), tokens)
  | (left, Operator Bang :: tokens) ->
    parse_l3_rest (Expression.UnaryOp (Factorialize, left), tokens)
  | (left, tokens) -> Ok (left, tokens)

and parse_l3 (tokens : Tokenizer.Token.t list) : parse_result =
  let* parsed = parse_l4 tokens in parse_l3_rest parsed

(* LAYER 2 - Multiplication, Division *)
and parse_l2_rest : Expression.t * Tokenizer.Token.t list -> parse_result = function
  | (left, Operator Asterisk :: tokens) ->
    let* (expr, rest) = parse_l3 tokens in
    parse_l2_rest (BinaryOp (left, Multiply, expr), rest)
  | (left, Operator Slash :: tokens) ->
    let* (expr, rest) = parse_l3 tokens in
    parse_l2_rest (BinaryOp (left, Divide, expr), rest)
  | (left, tokens) -> Ok (left, tokens)

and parse_l2 (tokens : Tokenizer.Token.t list) : parse_result =
  let* parsed = parse_l3 tokens in parse_l2_rest parsed

(* LAYER 1 - Addition, Subtraction *)
and parse_l1_rest : Expression.t * Tokenizer.Token.t list -> parse_result = function
  | (left, Operator Plus :: tokens) ->
    let* (expr, rest) = parse_l2 tokens in
    parse_l1_rest (BinaryOp (left, Add, expr), rest)
  | (left, Operator Minus :: tokens) ->
    let* (expr, rest) = parse_l2 tokens in
    parse_l1_rest (BinaryOp (left, Subtract, expr), rest)
  | (left, tokens) -> Ok (left, tokens)

and parse_l1 (tokens : Tokenizer.Token.t list) : parse_result =
  let* parsed = parse_l2 tokens in parse_l1_rest parsed

(* LAYER 0 - Boolean Binary Operations *)
and parse_l0_rest : Expression.t * Tokenizer.Token.t list -> parse_result = function
  | (left, Operator Equals :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, Equals, expr), rest)
  | (left, Operator GreaterThan :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, GreaterThan, expr), rest)
  | (left, Operator LessThan :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, LessThan, expr), rest)
  | (left, Operator GreaterEqual :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, GreaterOrEqual, expr), rest)
  | (left, Operator LessEqual :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, LessOrEqual, expr), rest)
  | (left, Keyword And :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, And, expr), rest)
  | (left, Keyword Or :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, Or, expr), rest)
  | (left, Keyword Xor :: tokens) ->
    let* (expr, rest) = parse_l1 tokens in
    parse_l0_rest (BinaryOp (left, Xor, expr), rest)
  | (left, tokens) -> Ok (left, tokens)

and parse_l0 (tokens : Tokenizer.Token.t list) : parse_result =
  let* parsed = parse_l1 tokens in parse_l0_rest parsed

(* BASE *)
let parse (tokens : Tokenizer.Token.t list) : (Expression.t, string) result = 
  let* parsed = parse_l0 tokens in
  match parsed with
  | (expr, []) -> Ok expr 
  | (_, rest)  -> Error ("Could not parse tokens: " ^ [%show: Tokenizer.Token.t list] rest)
