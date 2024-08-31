import gleam/bit_array
import gleam/int
import gleam/io
import gleam/string
import gleeunit/should
import lexer/lexer
import token/token

@internal
pub type TestNextTokenInput {
  TestNextTokenInput(expected: token.TokenType, expected_literal: String)
}

fn test_rec(l: lexer.Lexer, tests: List(TestNextTokenInput), tally: Int) -> Nil {
  case tests {
    [t, ..rest] -> {
      let #(next_l, next_token) = lexer.next_token(l)
      let assert Ok(str_ch) = bit_array.to_string(l.ch)
      io.debug(#(
        string.slice(l.input, l.position, 1),
        str_ch,
        t.expected,
        next_token.token_type,
      ))
      // io.debug(next_l)
      should.be_true(t.expected == next_token.token_type)
      test_rec(next_l, rest, tally + 1)
    }
    [] -> Nil
    // TODO: I don't know if this is the right way to do this
  }
}

pub fn next_token_test() {
  let input: String = "=+(){},;"
  // let input: String = "=+("
  let tests: List(TestNextTokenInput) = [
    TestNextTokenInput(token.TokenType(token.c_assign), "="),
    TestNextTokenInput(token.TokenType(token.c_plus), "+"),
    TestNextTokenInput(token.TokenType(token.c_lparen), "("),
    TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
    TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
    TestNextTokenInput(token.TokenType(token.c_rbrace), "}"),
    TestNextTokenInput(token.TokenType(token.c_comma), ","),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    TestNextTokenInput(token.TokenType(token.c_eof), ""),
  ]

  let l = lexer.new(input)
  test_rec(l, tests, 0)
}
