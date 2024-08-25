import gleam/io
import gleam/list
import gleeunit/should
import token/token

@internal
pub type TestNextTokenInput {
  TestNextTokenInput(expected: token.TokenType, expected_literal: String)
}

pub fn next_token_test() {
  let tests: List(TestNextTokenInput) = [
    TestNextTokenInput(token.TokenType(token.c_illegal), "ILLEGAL"),
    TestNextTokenInput(token.TokenType(token.c_eof), "EOF"),
    TestNextTokenInput(token.TokenType(token.c_ident), "IDENT"),
    TestNextTokenInput(token.TokenType(token.c_int), "INT"),
    TestNextTokenInput(token.TokenType(token.c_assign), "="),
    TestNextTokenInput(token.TokenType(token.c_plus), "+"),
    TestNextTokenInput(token.TokenType(token.c_comma), ","),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    TestNextTokenInput(token.TokenType(token.c_lparen), "("),
    TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
    TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
    TestNextTokenInput(token.TokenType(token.c_rbrace), "}"),
    TestNextTokenInput(token.TokenType(token.c_function), "FUNCTION"),
    TestNextTokenInput(token.TokenType(token.c_let), "LET"),
  ]

  // let l = fn() -> String { "" }
  list.each(tests, fn(t: TestNextTokenInput) -> Nil {
    let tokenized_expected = token.TokenType(t.expected_literal)
    io.println("TEST: " <> t.expected_literal)
    should.be_true(t.expected == tokenized_expected)
  })
}
