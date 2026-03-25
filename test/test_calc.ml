open Calc

let eval_test (expr : string) (expected : (float, string) result) =
  Alcotest.test_case expr `Quick (fun () ->
  Alcotest.(check (result (float 1e-6) string)) expr expected
    (Calculator.calculate expr))

let eval_test_ok expr expected = eval_test expr (Ok expected)

let eval_test_err (expr : string) =
  Alcotest.test_case expr `Quick (fun () ->
  Alcotest.(check bool) expr true
    (Result.is_error (Calculator.calculate expr)))

let () =
  Alcotest.run "Tests" [
    "evaluator", [
      eval_test_ok "Pi" 3.141592653589793;
      eval_test_ok "E" 2.71828;
      eval_test_ok "1234567890" 1234567890.;
      eval_test_ok "1 + 1" 2.;
      eval_test_ok "9 + 8" 17.;
      eval_test_ok "9 - 7" 2.;
      eval_test_ok "6 * 3" 18.;
      eval_test_ok "8 / 2" 4.;
      eval_test_ok "5^2" 25.;
      eval_test_ok "-5^2" (-25.);
      eval_test_ok "x <- 5" 5.;
      eval_test_ok "3 + x" 8.;
      eval_test_err "3 + y";
      eval_test_err "Foo <- 5";
      eval_test_err "3 + Foo";
    ];
  ]
