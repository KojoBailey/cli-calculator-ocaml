open Calc

open Printf

let rec main () =
  print_string ">>> ";
  let input = read_line () in
  begin match Calculator.calculate input with
  | Ok result -> print_endline (string_of_float result)
  | Error err -> printf "[ERROR] %s\n" err
  end;
  if !Calculator.show_debug then
    print_endline "";
  main ()

let truth_values = ["true"; "True"; "t"; "T"; "1"; "y"; "Y"; "yes"; "Yes"]

let () =
  Calculator.show_debug := Array.length Sys.argv > 1 && List.mem Sys.argv.(1) truth_values;
  main ()
