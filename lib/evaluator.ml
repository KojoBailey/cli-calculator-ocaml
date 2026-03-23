let ( let* ) = Result.bind

let safe_div (n : float) (d : float) : (float, string) result =
  if d = 0.
    then Error "Division by zero."
    else Ok (n /. d)

let get_unary_op (operator : Parser.Expression.un_op) : float -> (float, string) result =
  match operator with
    | Parser.Expression.Negative -> fun (x : float) -> Ok (-. x)

let get_binary_op (operator : Parser.Expression.bin_op) : float -> float -> (float, string) result =
  match operator with
    | Parser.Expression.Add      -> fun (x : float) (y : float) -> Ok (x +. y)
    | Parser.Expression.Subtract -> fun (x : float) (y : float) -> Ok (x -. y)
    | Parser.Expression.Multiply -> fun (x : float) (y : float) -> Ok (x *. y)
    | Parser.Expression.Divide   -> safe_div

let rec evaluate (expr : Parser.Expression.t) : (float, string) result =
  match expr with
    | Parser.Expression.Number n -> Ok n
    | Parser.Expression.BinaryOp (left, operator, right) ->
        let* left' = evaluate left in
        let* right' = evaluate right in
        (get_binary_op operator) left' right'
    | Parser.Expression.UnaryOp (operator, value) ->
        let* value' = evaluate value in
        (get_unary_op operator) value'
