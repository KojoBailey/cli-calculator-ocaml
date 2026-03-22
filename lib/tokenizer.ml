module Token = struct
  type operator = Plus | Minus | Asterisk | Slash
  [@@deriving show]
  
  type t =
    | Number of float (* Easier to just evaluate one number type. *)
    | Operator of operator
    | ParenthesisOpen
    | ParenthesisClose
  [@@deriving show]
end

let is_digit (c : char) : bool = c >= '0' && c <= '9'
let is_float_literal_char (c : char) : bool = is_digit c || c == '.'

(* Does not check for and crashes on invalid input. *)
(* An example of invalid input is "6..9". *)
let parse_num (input : char list) : float * char list =
  let str = String.of_seq (List.to_seq (List.take_while is_float_literal_char input)) in
  (float_of_string str, List.drop_while is_float_literal_char input)

let tokenize (input : string) : (Token.t list, string) result  = 
  let chars = List.of_seq (String.to_seq input) in
  let rec token_map token cs = Result.map (fun ts -> token :: ts) (go cs)
  and go = function
    | []        -> Ok []
    | ' ' :: cs -> go cs
    | '(' :: cs -> token_map Token.ParenthesisOpen cs
    | ')' :: cs -> token_map Token.ParenthesisClose cs
    | '+' :: cs -> token_map (Token.Operator Plus) cs
    | '-' :: cs -> token_map (Token.Operator Minus) cs
    | '*' :: cs -> token_map (Token.Operator Asterisk) cs
    | '/' :: cs -> token_map (Token.Operator Slash) cs
    | c :: cs when is_digit c ->
        let (num, remaining) = parse_num (c :: cs) in
        token_map (Token.Number num) remaining
    | c :: _ -> Error ("Invalid token: " ^ String.make 1 c)
  in
  go chars
