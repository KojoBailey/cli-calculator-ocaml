open Calc

open Printf

let ( let* ) = Result.bind

let show_debug = ref false

let calculate (input : string) : (float, string) result =
  let* tokens = Tokenizer.tokenize input in
  if !show_debug then begin
    print_endline "=== Tokens ===";
    print_endline ([%show: Tokenizer.Token.t list] tokens);
    print_endline ""
  end;
  let* ast = Parser.parse tokens in
  if !show_debug then begin
    print_endline "=== Abstract Syntax Tree ===";
    print_endline ([%show: Parser.Expression.t] ast);
    print_endline ""
  end;
  let* result = Evaluator.evaluate ast in
  if !show_debug then
    print_endline "=== Result ===";
  Ok result

let rec main () =
  print_string ">>> ";
  let input = read_line () in
  begin match calculate input with
  | Ok result -> print_endline (string_of_float result)
  | Error err -> printf "Error: %s\n" err
  end;
  if !show_debug then
    print_endline "";
  main ()

let truth_values = ["true"; "True"; "t"; "T"; "1"; "y"; "Y"; "yes"; "Yes"]

let () =
  show_debug := Array.length Sys.argv > 1 && List.mem Sys.argv.(1) truth_values;
  main ()
