import gleam/bit_array
import gleam/io
import gleam/list
import gleam/string_builder
import gleeunit/should
import lexer/lexer
import token/token

// WARNING: Good luck trying to read this on github, using @internal breaks syntax highlighting :D
@internal
pub type TestNextTokenInput {
  TestNextTokenInput(expected: token.TokenType, expected_literal: String)
}

fn test_rec(l: lexer.Lexer, tests: List(TestNextTokenInput), tally: Int) -> Nil {
  case tests {
    [t, ..rest] -> {
      let #(next_l, next_token) = lexer.next_token(l)
      io.debug(#(t.expected_literal, t.expected, next_token.token_type))
      should.be_true(t.expected == next_token.token_type)
      test_rec(next_l, rest, tally + 1)
    }
    [] -> Nil
  }
}

pub fn next_token_test() {
  let input_one: String =
    "
    let five = 5;
    let ten = 10;

    let add = fn(x, y) {
      x + y;
    };

    let result = add(five,ten);
    !-/*5;
    5 < 10 > 5;
    if (5 < 10) {
      return true;
    } else {
      return false 
    }

    10 == 10;
    10 != 9;
    "
  let test_one: List(TestNextTokenInput) = [
    //    "let five = 5;
    TestNextTokenInput(token.TokenType(token.c_let), "let"),
    TestNextTokenInput(token.TokenType(token.c_ident), "five"),
    TestNextTokenInput(token.TokenType(token.c_assign), "="),
    TestNextTokenInput(token.TokenType(token.c_int), "5"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    //let ten = 10;
    TestNextTokenInput(token.TokenType(token.c_let), "let"),
    TestNextTokenInput(token.TokenType(token.c_ident), "ten"),
    TestNextTokenInput(token.TokenType(token.c_assign), "="),
    TestNextTokenInput(token.TokenType(token.c_int), "10"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    // let add = fn(x, y) {
    TestNextTokenInput(token.TokenType(token.c_let), "let"),
    TestNextTokenInput(token.TokenType(token.c_ident), "add"),
    TestNextTokenInput(token.TokenType(token.c_assign), "="),
    TestNextTokenInput(token.TokenType(token.c_function), "fn"),
    TestNextTokenInput(token.TokenType(token.c_lparen), "("),
    TestNextTokenInput(token.TokenType(token.c_ident), "x"),
    TestNextTokenInput(token.TokenType(token.c_comma), ","),
    TestNextTokenInput(token.TokenType(token.c_ident), "y"),
    TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
    TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
    //x + y;
    TestNextTokenInput(token.TokenType(token.c_ident), "x"),
    TestNextTokenInput(token.TokenType(token.c_plus), "+"),
    TestNextTokenInput(token.TokenType(token.c_ident), "y"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    // };
    TestNextTokenInput(token.TokenType(token.c_rbrace), "}"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    // let result = add(five,ten);
    TestNextTokenInput(token.TokenType(token.c_let), "let"),
    TestNextTokenInput(token.TokenType(token.c_ident), "result"),
    TestNextTokenInput(token.TokenType(token.c_assign), "="),
    TestNextTokenInput(token.TokenType(token.c_ident), "add"),
    TestNextTokenInput(token.TokenType(token.c_lparen), "("),
    TestNextTokenInput(token.TokenType(token.c_ident), "five"),
    TestNextTokenInput(token.TokenType(token.c_comma), ","),
    TestNextTokenInput(token.TokenType(token.c_ident), "ten"),
    TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    // !-/*5;
    TestNextTokenInput(token.TokenType(token.c_bang), "!"),
    TestNextTokenInput(token.TokenType(token.c_minus), "-"),
    TestNextTokenInput(token.TokenType(token.c_slash), "/"),
    TestNextTokenInput(token.TokenType(token.c_asterisk), "*"),
    TestNextTokenInput(token.TokenType(token.c_int), "5"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    // 5 < 10 > 5;
    TestNextTokenInput(token.TokenType(token.c_int), "5"),
    TestNextTokenInput(token.TokenType(token.c_lt), "<"),
    TestNextTokenInput(token.TokenType(token.c_int), "10"),
    TestNextTokenInput(token.TokenType(token.c_gt), ">"),
    TestNextTokenInput(token.TokenType(token.c_int), "5"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    //    if (5 < 10) {
    TestNextTokenInput(token.TokenType(token.c_if), "if"),
    TestNextTokenInput(token.TokenType(token.c_lparen), "("),
    TestNextTokenInput(token.TokenType(token.c_int), "5"),
    TestNextTokenInput(token.TokenType(token.c_lt), "<"),
    TestNextTokenInput(token.TokenType(token.c_int), "10"),
    TestNextTokenInput(token.TokenType(token.c_rparen), ")"),
    TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
    //   return true;
    TestNextTokenInput(token.TokenType(token.c_return), "return"),
    TestNextTokenInput(token.TokenType(token.c_true), "true"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), "c_semicolon"),
    // } else {
    TestNextTokenInput(token.TokenType(token.c_rbrace), "}"),
    TestNextTokenInput(token.TokenType(token.c_else), "else"),
    TestNextTokenInput(token.TokenType(token.c_lbrace), "{"),
    //   return false 
    TestNextTokenInput(token.TokenType(token.c_return), "return"),
    TestNextTokenInput(token.TokenType(token.c_false), "false"),
    // }
    TestNextTokenInput(token.TokenType(token.c_rbrace), "}"),
    // 10 == 10;
    TestNextTokenInput(token.TokenType(token.c_int), "10"),
    TestNextTokenInput(token.TokenType(token.c_eq), "=="),
    TestNextTokenInput(token.TokenType(token.c_int), "10"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    // 10 != 9;
    //
    TestNextTokenInput(token.TokenType(token.c_int), "10"),
    TestNextTokenInput(token.TokenType(token.c_not_eq), "!="),
    TestNextTokenInput(token.TokenType(token.c_int), "9"),
    TestNextTokenInput(token.TokenType(token.c_semicolon), ";"),
    TestNextTokenInput(token.TokenType(token.c_eof), ""),
  ]
  let l = lexer.new(input_one)
  test_rec(l, test_one, 0)
}

@internal
pub type TestIsLetterOrUnderscoreInput {
  TestIsLetterOrUnderscoreInput(expected: Bool, input: BitArray)
}

pub fn is_ascii_letter_test() {
  let tests: List(TestIsLetterOrUnderscoreInput) = [
    TestIsLetterOrUnderscoreInput(True, <<"a":utf8>>),
    TestIsLetterOrUnderscoreInput(True, <<"A":utf8>>),
    TestIsLetterOrUnderscoreInput(True, <<"z":utf8>>),
    TestIsLetterOrUnderscoreInput(True, <<"Z":utf8>>),
    TestIsLetterOrUnderscoreInput(True, <<"_":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"!":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"@":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"#":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"0":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"2":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<" ":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"\n":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"\r":utf8>>),
    TestIsLetterOrUnderscoreInput(False, <<"\t":utf8>>),
  ]
  list.each(tests, fn(t) {
    should.be_true(t.expected == lexer.is_letter_or_underscore(t.input))
  })
}

@internal
pub type TestReadIdentifiers {
  TestReadIdentifiers(expected: String, input: String)
}

pub fn read_identifier_test() {
  let tests: List(TestReadIdentifiers) = [
    TestReadIdentifiers("hello", "hello"),
    TestReadIdentifiers("two", "two words"),
    TestReadIdentifiers(
      "identifier_with_underscore",
      "identifier_with_underscore fart",
    ),
    TestReadIdentifiers("numeric", "numeric235"),
  ]

  tests
  |> list.each(fn(t) -> Nil {
    let lex = lexer.new(t.input)
    let result = lexer.read_identifier(lex, string_builder.new())
    let string_result = result.1
    should.be_true(t.expected == string_result)
  })
}

@internal
pub type TestPeekCharInput {
  TestPeekCharInput(expected: BitArray, input: String)
}

pub fn peek_char_test() {
  let tests: List(TestPeekCharInput) = [TestPeekCharInput(<<"a":utf8>>, "ba")]
  tests
  |> list.each(fn(t) -> Nil {
    let lex = lexer.new(t.input)
    let result = lexer.peek_char(lex)
    should.be_true(t.expected == result)
  })
}
