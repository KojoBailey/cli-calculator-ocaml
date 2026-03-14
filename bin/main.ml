open Calc

let () =
  match Tokenizer.tokenize "6.9 * -(7/3 + 2)" with
  | Ok tokens -> print_endline ([%show: Tokenizer.Token.t list] tokens)
  | Error err -> Printf.printf "Error: %s\n" err
