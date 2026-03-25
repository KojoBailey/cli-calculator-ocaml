open Variables

let ( let* ) = Result.bind

let show_debug = ref false

let calculate (input : string) : (float, string) result =
  let* tokens = Tokenizer.tokenize input in
  if !show_debug then begin
    print_endline "=== Tokens ===";
    print_endline ([%show: Tokenizer.Token.t list] tokens);
    print_endline ""
  end;
  let assign_target : string option ref = ref None in
  let tokens' = begin match tokens with
  | Tokenizer.Token.Identifier id :: Tokenizer.Token.Operator LeftArrow :: ts ->
      assign_target := Some id;
      ts
  | ts -> ts
  end in
  let* ast = Parser.parse tokens' in
  if !show_debug then begin
    print_endline "=== Abstract Syntax Tree ===";
    print_endline ([%show: Parser.Expression.t] ast);
    print_endline ""
  end;
  let* result = Evaluator.evaluate ast in
  begin match !assign_target with
  | Some id ->
    if not (Hashtbl.mem variable_handles id)
    then begin
      Dynarray.add_last variables result;
      let index = Dynarray.length variables - 1 in
      Hashtbl.add variable_handles id index
    end else
      Dynarray.set variables (Hashtbl.find variable_handles id) result
  | None -> ()
  end;
  if !show_debug then
    print_endline "=== Result ===";
  Ok result

