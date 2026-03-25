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
      eval_test_ok "True" 1.;
      eval_test_ok "False" 0.;
      eval_test_ok "Pi" 3.141592653589793;
      eval_test_ok "E" 2.71828;
      eval_test_ok "1234567890" 1234567890.;
      eval_test_err "1 ++ 2";
      eval_test_err "+ 2";
      eval_test_err "5 +* 3";
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
      eval_test_ok "100%" 1.;
      eval_test_ok "42%" 0.42;
      eval_test_ok "5^2%" 0.25;
      eval_test_err "%2";
      eval_test_ok "5!" 120.;
      eval_test_ok "0!" 1.;
      eval_test_ok "1!" 1.;
      eval_test_ok "-5!" (-120.);
      eval_test_err "(-5)!";
      eval_test_err "!5";
      eval_test_err "4.2!";
      eval_test_ok "5 = 5" 1.;
      eval_test_ok "5 = 3" 0.;
      eval_test_ok "5 > 3" 1.;
      eval_test_ok "3 > 5" 0.;
      eval_test_ok "5 > 5" 0.;
      eval_test_ok "5 < 3" 0.;
      eval_test_ok "3 < 5" 1.;
      eval_test_ok "5 < 5" 0.;
      eval_test_ok "5 >= 3" 1.;
      eval_test_ok "3 >= 5" 0.;
      eval_test_ok "5 >= 5" 1.;
      eval_test_ok "5 <= 3" 0.;
      eval_test_ok "3 <= 5" 1.;
      eval_test_ok "5 <= 5" 1.;
      eval_test_ok "not (5 = 3)" 1.;
      eval_test_ok "not (5 = 5)" 0.;
      eval_test_ok "True and True" 1.;
      eval_test_ok "True and False" 0.;
      eval_test_ok "False and True" 0.;
      eval_test_ok "False and False" 0.;
      eval_test_ok "5 and 3" 1.;
      eval_test_ok "False and False" 0.;
      eval_test_ok "True or True" 1.;
      eval_test_ok "False or True" 1.;
      eval_test_ok "True or False" 1.;
      eval_test_ok "False or False" 0.;
      eval_test_ok "5 or 3" 1.;
      eval_test_ok "True xor True" 0.;
      eval_test_ok "False xor True" 1.;
      eval_test_ok "True xor False" 1.;
      eval_test_ok "False xor False" 0.;
      eval_test_ok "0 xor 3" 1.;
      eval_test_err "and <- 5";
    ];
  ]
