let constants : (string, float) Hashtbl.t =
  let t = Hashtbl.create 2 in
  List.iter (fun (k, v) -> Hashtbl.replace t k v) [
    ("True", 1.);
    ("False", 0.);
    ("Pi", 3.141592653589793);
    ("E", 2.71828);
  ];
  t
