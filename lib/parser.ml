module Expression = struct
  type bin_op = Add | Subtract | Multiply | Divide
  [@@deriving show]

  type un_op = Negative
  [@@deriving show]

  type t =
    | BinaryOp of t * bin_op * t
    | UnaryOp of un_op * t
    | Number of float
  [@@deriving show]
end

let ( let* ) = Result.bind

type parse_result = (Expression.t * Tokenizer.Token.t list, string) result

let rec parse_l3 (tokens : Tokenizer.Token.t list) : parse_result =
  match tokens with
    | Tokenizer.Token.ParenthesisOpen :: ts ->
        let* (expr, rest) = parse_l1 ts in
          begin match rest with
            | Tokenizer.Token.ParenthesisClose :: rest' -> Ok (expr, rest')
            | _ -> Error "Missing closing parenthesis."
          end
    | Tokenizer.Token.Operator Minus :: ts ->
        let* (expr, rest) = parse_l3 ts in
        Ok (Expression.UnaryOp (Negative, expr), rest)
    | Tokenizer.Token.Number n :: ts -> Ok (Expression.Number n, ts)
    | [] -> Error "Unexpected end of expression."
    | t :: _ -> Error ("Unexpected token: " ^ [%show: Tokenizer.Token.t] t)

and parse_l2_rest (input : Expression.t * Tokenizer.Token.t list) : parse_result =
  match input with
    | (left, Tokenizer.Token.Operator Asterisk :: tokens) ->
        let* (expr, rest) = parse_l3 tokens in
        parse_l2_rest (Expression.BinaryOp (left, Multiply, expr), rest)
    | (left, Tokenizer.Token.Operator Slash :: tokens) ->
        let* (expr, rest) = parse_l3 tokens in
        parse_l2_rest (Expression.BinaryOp (left, Divide, expr), rest)
    | (left, tokens) -> Ok (left, tokens)

and parse_l2 (tokens : Tokenizer.Token.t list) : parse_result =
  let* parsed = parse_l3 tokens in parse_l2_rest parsed

and parse_l1_rest (input : Expression.t * Tokenizer.Token.t list) : parse_result =
  match input with
    | (left, Tokenizer.Token.Operator Plus :: tokens) ->
        let* (expr, rest) = parse_l2 tokens in
        parse_l1_rest (Expression.BinaryOp (left, Add, expr), rest)
    | (left, Tokenizer.Token.Operator Minus :: tokens) ->
        let* (expr, rest) = parse_l2 tokens in
        parse_l1_rest (Expression.BinaryOp (left, Subtract, expr), rest)
    | (left, tokens) -> Ok (left, tokens)

and parse_l1 (tokens : Tokenizer.Token.t list) : parse_result =
  let* parsed = parse_l2 tokens in parse_l1_rest parsed

let parse (tokens : Tokenizer.Token.t list) : (Expression.t, string) result = 
  let* parsed = parse_l1 tokens in
  match parsed with
    | (expr, []) -> Ok expr 
    | (_, rest)  -> Error ("Could not parse tokens: " ^ [%show: Tokenizer.Token.t list] rest)
