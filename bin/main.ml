open Calc

let () =
  match Tokenizer.tokenize "6.9 * -(7/3 + 2)" with
  | Ok tokens ->
      print_endline ([%show: Tokenizer.Token.t list] tokens);
      print_endline "";
      begin match Parser.parse tokens with
        | Ok ast -> print_endline ([%show: Parser.Expression.t] ast)
        | Error err -> Printf.printf "Error: %s\n" err
      end
  | Error err -> Printf.printf "Error: %s\n" err
