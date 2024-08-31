import gleam/bit_array
import gleam/bytes_builder
import gleam/order
import gleam/string
import token/token

pub type Lexer {
  Lexer(input: String, position: Int, read_position: Int, ch: BitArray)
}

pub fn new(input: String) -> Lexer {
  Lexer(input, 0, 0, <<>>)
  |> read_char()
}

pub fn read_char(l: Lexer) -> Lexer {
  case l.read_position >= string.length(l.input) {
    // the <<>> is a bit array of length 0, which is what we want for "" (aka EOF / empty)
    True -> Lexer(l.input, l.read_position, l.read_position + 1, <<>>)
    _ ->
      Lexer(
        l.input,
        l.read_position,
        l.read_position + 1,
        bytes_builder.new()
          |> bytes_builder.append_string(string.slice(
            l.input,
            l.read_position,
            1,
          ))
          |> bytes_builder.to_bit_array,
      )
  }
}

// TODO: I don't know if tuples are how you're supposed to return multiple values, oh well :)
pub fn next_token(l: Lexer) -> #(Lexer, token.Token) {
  let assert Ok(ch_str) = bit_array.to_string(l.ch)
  let next_lex = read_char(l)
  case l.ch {
    _ if ch_str == "=" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_assign), "="),
    )
    _ if ch_str == ";" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_semicolon), ";"),
    )
    _ if ch_str == "(" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_lparen), "("),
    )
    _ if ch_str == ")" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_rparen), ")"),
    )
    _ if ch_str == "," -> #(
      next_lex,
      token.Token(token.TokenType(token.c_comma), ","),
    )
    _ if ch_str == "+" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_plus), "+"),
    )
    _ if ch_str == "{" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_lbrace), "{"),
    )
    _ if ch_str == "}" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_rbrace), "}"),
    )
    _ if ch_str == "" -> #(
      next_lex,
      token.Token(token.TokenType(token.c_eof), ""),
    )
    _ -> #(next_lex, token.Token(token.TokenType(token.c_illegal), ""))
  }
}

fn read_identifier(l: Lexer) -> #(Lexer, String) {
  todo
}

// https://www.asciitable.com/
pub fn is_letter_or_underscore(ch: BitArray) -> Bool {
  let assert Ok(str_ch) = bit_array.to_string(ch)

  // WARNING: prob better to handle with a case on the order type maybe?
  let comp_lower_a = string.compare(str_ch, "a") |> order.to_int
  let comp_lower_z = string.compare(str_ch, "z") |> order.to_int
  let comp_upper_a = string.compare(str_ch, "A") |> order.to_int
  let comp_upper_z = string.compare(str_ch, "Z") |> order.to_int

  let is_lower = comp_lower_a == 0 || comp_lower_z == 0
  let is_upper = comp_upper_a == 0 || comp_upper_z == 0

  case str_ch {
    "_" -> True
    _ if is_lower -> True
    _ if is_upper -> True
    _ -> False
  }
}
