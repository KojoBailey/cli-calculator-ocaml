open Calc

open Printf

let rec main () =
  print_string ">>> ";
  let input = read_line () in
  match Tokenizer.tokenize input with
  | Ok tokens ->
      print_endline ([%show: Tokenizer.Token.t list] tokens);
      print_endline "";
      begin match Parser.parse tokens with
        | Ok ast ->
            print_endline ([%show: Parser.Expression.t] ast);
            print_endline "";
            begin match Evaluator.evaluate ast with
              | Ok result ->
                  print_endline (string_of_float result);
                  main ()
              | Error err -> printf "Error: %s\n" err; main ()
            end
        | Error err -> printf "Error: %s\n" err; main ()
      end
  | Error err -> printf "Error: %s\n" err; main ()

let () = main ()
