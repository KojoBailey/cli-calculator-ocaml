let ( let* ) = Result.bind

type 'a or_error = ('a, string) result

let safe_div (n : float) (d : float) : float or_error =
  if d = 0.
    then Error "Division by zero."
    else Ok (n /. d)

let rec factorial : int -> int or_error = function
  | n when n < 0 -> Error "Cannot take factoral of negative value."
  | 0 | 1 -> Ok 1
  | n -> let* rest = factorial (n - 1) in Ok (n * rest)

let float_as_bool f : bool = f <> 0.
let bool_as_float b : float = if b then 1. else 0.

let get_unary_op : Parser.Expression.un_op -> float -> float or_error = function
  | Negative     -> fun x -> Ok (-. x)
  | Percentage   -> fun x -> Ok (x /. 100.)
  | Factorialize -> fun x -> if Float.is_integer x
    then let* res = factorial (int_of_float x) in Ok (float_of_int res)
    else Error ("Cannot take factorial of non-integer value: " ^ string_of_float x)
  | Not          -> fun x -> Ok (bool_as_float (not (float_as_bool x)))

let get_binary_op : Parser.Expression.bin_op -> float -> float -> float or_error = function
  | Add            -> fun x y -> Ok (x +. y)
  | Subtract       -> fun x y -> Ok (x -. y)
  | Multiply       -> fun x y -> Ok (x *. y)
  | Divide         -> safe_div
  | Exponentiate   -> fun x y -> Ok (Float.pow x y)
  | Equals         -> fun x y -> Ok (bool_as_float (x = y))
  | GreaterThan    -> fun x y -> Ok (bool_as_float (x > y))
  | LessThan       -> fun x y -> Ok (bool_as_float (x < y))
  | GreaterOrEqual -> fun x y -> Ok (bool_as_float (x >= y))
  | LessOrEqual    -> fun x y -> Ok (bool_as_float (x <= y))
  | And            -> fun x y -> Ok (bool_as_float (float_as_bool x && float_as_bool y))
  | Or             -> fun x y -> Ok (bool_as_float (float_as_bool x || float_as_bool y))
  | Xor            -> fun x y -> Ok (bool_as_float (float_as_bool x <> float_as_bool y))

let rec evaluate : Parser.Expression.t -> float or_error = function
  | Number n -> Ok n
  | Variable handle -> Ok (Dynarray.get Variables.variables handle)
  | BinaryOp (left, operator, right) ->
    let* left' = evaluate left in
    let* right' = evaluate right in
    (get_binary_op operator) left' right'
  | UnaryOp (operator, value) ->
    let* value' = evaluate value in
    (get_unary_op operator) value'
