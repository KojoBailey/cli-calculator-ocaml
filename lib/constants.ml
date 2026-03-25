let constants : (string, float) Hashtbl.t =
  let t = Hashtbl.create 2 in
  List.iter (fun (k, v) -> Hashtbl.replace t k v) [
    ("True", 1.);
    ("False", 0.);
    ("Pi", Float.pi);
    ("E", 2.71828);
  ];
  t

let maths_mod x y =
  let r = mod_float x y in
  if r < 0. then r +. y else r

let sin x = match maths_mod x (2. *. Float.pi) with
  | n when n = Float.pi             -> 0.
  | n when n = Float.pi /. 2.       -> 1.
  | n when n = 3. *. Float.pi /. 2. -> -.1.
  | n -> Float.sin n

let cos x = sin (x +. Float.pi /. 2.)

let builtin_functions : (string, float -> float) Hashtbl.t =
  let t = Hashtbl.create 1 in
  List.iter (fun (k, v) -> Hashtbl.replace t k v) [
    ("Abs", fun x -> if x < 0. then -.x else x);
    ("Sin", sin);
    ("Cos", cos);
  ];
  t
