module Token = struct
  type operator =
  | Plus
  | Minus
  | Asterisk
  | Slash
  | LeftArrow
  [@@deriving show]
  
  type t =
    | Number of float (* Easier to just evaluate one number type. *)
    | Operator of operator
    | ParenthesisOpen
    | ParenthesisClose
    | Identifier of string
  [@@deriving show]
end

let digit_to_char (n : int) : char = Char.chr (Char.code '0' + n)

let valid_identifier_chars : char list =
  let lowercase_chars = List.init 26 (fun i -> Char.chr (Char.code 'a' + i)) in
  let uppercase_chars = List.init 26 (fun i -> Char.chr (Char.code 'A' + i)) in
  let numbers = List.init 10 (fun i -> digit_to_char i) in
  '_' :: lowercase_chars @ uppercase_chars @ numbers

let parse_identifier (cs : char list) : string * char list =
  let condition c = List.mem c valid_identifier_chars in
  let char_list = List.take_while condition cs in
  let word = String.of_seq (List.to_seq char_list) in
  let rest = List.drop_while condition cs in
  (word, rest)

let is_identifier (cs : char list) : bool =
  let lowercase_chars = List.init 26 (fun i -> Char.chr (Char.code 'a' + i)) in
  if not (List.mem (List.hd cs) lowercase_chars) then false
  else
    let word = List.take_while (fun c -> List.mem c valid_identifier_chars) cs in
    List.fold_left (fun acc c -> acc && List.mem c valid_identifier_chars) true word

let is_digit (c : char) : bool = c >= '0' && c <= '9'
let is_float_literal_char (c : char) : bool = is_digit c || c = '.'

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
    | '<' :: '-' :: cs -> token_map (Token.Operator LeftArrow) cs
    | c :: cs when is_digit c ->
      let (num, remaining) = parse_num (c :: cs) in
      token_map (Token.Number num) remaining
    | cs when is_identifier cs ->
      let (identifier, remaining) = parse_identifier cs in
      token_map (Token.Identifier identifier) remaining
    | c :: _ -> Error ("Invalid token: " ^ String.make 1 c)
  in
  go chars
