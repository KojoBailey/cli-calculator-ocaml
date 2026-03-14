module Token = struct
  type operator = Plus | Minus | Asterisk | Slash
  [@@deriving show]
  
  type t =
    | Number of float
    | Operator of operator
    | ParenthesisOpen
    | ParenthesisClose
  [@@deriving show]
end

let tokenize input = 
  let chars = List.of_seq (String.to_seq input) in
  let rec go = function
    | []        -> Ok []
    | ' ' :: cs -> go cs
    | c :: cs   -> Error ("Invalid token: " ^ String.make 1 c)
  in
  go chars
