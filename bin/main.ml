open Calc

let () =
  match Tokenizer.tokenize " They call me the OCamel" with
  | Ok tokens -> print_endline ([%show: Tokenizer.Token.t list] tokens)
  | Error err -> Printf.printf "Error: %s\n" err
