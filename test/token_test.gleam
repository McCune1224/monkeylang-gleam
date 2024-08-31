import gleam/bit_array
import gleam/io
import gleam/list
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

// pub fn next_token_test() {
//   let input: String =
//     "let five = 5;
//     let ten = 10;
//
//     let add = fn(x, y) {
//       x + y;
//     };
//
//     let result = add(five,ten);
//     "
//   // let input: String = "=+("
//   let tests: List(TestNextTokenInput) = [
//     TestNextTokenInput(token.TokenType(token.c_let), "let"),
//     TestNextTokenInput(token.TokenType(token.c_ident), "five"),
//     TestNextTokenInput(token.TokenType(token.c_assign), "="),
//     TestNextTokenInput(token.TokenType(token.c_int), "5"),
//     TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
//     TestNextTokenInput(token.TokenType(token.c_let), "let"),
//     TestNextTokenInput(token.TokenType(token.c_ident), "ten"),
//     TestNextTokenInput(token.TokenType(token.c_assign), "="),
//     TestNextTokenInput(token.TokenType(token.c_int), "10"),
//     TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
//     TestNextTokenInput(token.TokenType(token.c_let), "let"),
//     TestNextTokenInput(token.TokenType(token.c_ident), "add"),
//     TestNextTokenInput(token.TokenType(token.c_assign), "="),
//     TestNextTokenInput(token.TokenType(token.c_function), "fn"),
//     TestNextTokenInput(token.TokenType(token.c_lparen), "("),
//     TestNextTokenInput(token.TokenType(token.c_ident), "x"),
//     TestNextTokenInput(token.TokenType(token.c_comma), ","),
//     TestNextTokenInput(token.TokenType(token.c_ident), "y"),
//     TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
//     TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
//     TestNextTokenInput(token.TokenType(token.c_ident), "x"),
//     TestNextTokenInput(token.TokenType(token.c_plus), "+"),
//     TestNextTokenInput(token.TokenType(token.c_ident), "y"),
//     TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
//     TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
//     TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
//     TestNextTokenInput(token.TokenType(token.c_let), "let"),
//     TestNextTokenInput(token.TokenType(token.c_ident), "result"),
//     TestNextTokenInput(token.TokenType(token.c_assign), "="),
//     TestNextTokenInput(token.TokenType(token.c_ident), "add"),
//     TestNextTokenInput(token.TokenType(token.c_lparen), "("),
//     TestNextTokenInput(token.TokenType(token.c_ident), "five"),
//     TestNextTokenInput(token.TokenType(token.c_comma), ","),
//     TestNextTokenInput(token.TokenType(token.c_ident), "ten"),
//     TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
//     TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
//     TestNextTokenInput(token.TokenType(token.c_eof), ""),
//   ]
//   let l = lexer.new(input)
//   test_rec(l, tests, 0)
// }

// pub fn next_token_test() {
//   let input: String = "=+(){},;"
//   // let input: String = "=+("
//   let tests: List(TestNextTokenInput) = [
//     TestNextTokenInput(token.TokenType(token.c_assign), "="),
//     TestNextTokenInput(token.TokenType(token.c_plus), "+"),
//     TestNextTokenInput(token.TokenType(token.c_lparen), "("),
//     TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
//     TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
//     TestNextTokenInput(token.TokenType(token.c_rbrace), "}"),
//     TestNextTokenInput(token.TokenType(token.c_comma), ","),
//     TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
//     TestNextTokenInput(token.TokenType(token.c_eof), ""),
//   ]
//
//   let l = lexer.new(input)
//   test_rec(l, tests, 0)
// }
//
//

@internal
pub type TestIsLetterOrUnderscoreInput {
  TestIsLetterOrUnderscoreInput(expected: Bool, input: BitArray)
}

pub fn is_ascii_letter_test() {
  let tests: List(TestIsLetterOrUnderscoreInput) = [
    TestIsLetterOrUnderscoreInput(True, <<0b0110_0001>>),
    // a
    TestIsLetterOrUnderscoreInput(False, <<0b0010_0001>>),
    //!
  ]
  list.each(tests, fn(t) {
    io.debug(lexer.is_letter_or_underscore(t.input))
    let _ = io.debug(bit_array.to_string(t.input))

    should.be_true(t.expected == lexer.is_letter_or_underscore(t.input))
  })
  // let assert True = lexer.is_ascii_letter(<<0x7A>>)
  // let assert True = lexer.is_ascii_letter(<<0x41>>)
  // let assert True = lexer.is_ascii_letter(<<0x5A>>)
  // let assert False = lexer.is_ascii_letter(<<0x3A>>)
  // let assert False = lexer.is_ascii_letter(<<0x5F>>)
  // let assert False = lexer.is_ascii_letter(<<0x20>>)
  // let assert False = lexer.is_ascii_letter(<<0x7F>>)
}
