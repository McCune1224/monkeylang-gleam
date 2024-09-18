import gleam/bit_array
import gleam/bytes_builder
import gleam/io
import gleam/string
import gleam/string_builder
import token/token

pub type Lexer {
  Lexer(input: String, position: Int, read_position: Int, ch: BitArray)
}

pub fn new(input: String) -> Lexer {
  Lexer(input, 0, 0, <<>>)
  |> read_char()
}

pub fn skip_whitespace(l: Lexer) -> Lexer {
  let is_whitespace = fn(ch: BitArray) -> Bool {
    case ch {
      <<32:int>> -> True
      <<09:int>> -> True
      <<10:int>> -> True
      <<13:int>> -> True
      _ -> False
    }
  }
  case is_whitespace(l.ch) {
    True -> skip_whitespace(read_char(l))
    _ -> l
  }
}

// https://www.asciitable.com/
pub fn is_letter_or_underscore(ch: BitArray) -> Bool {
  case ch {
    <<code:int>> if code >= 65 && code <= 90 -> True
    <<code:int>> if code >= 97 && code <= 122 -> True
    <<"_":utf8>> -> True
    _ -> False
  }
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

pub fn is_digit(ch: BitArray) -> Bool {
  case ch {
    <<code:int>> if code >= 48 && code <= 57 -> True
    _ -> False
  }
}

pub fn read_number(
  l: Lexer,
  sb: string_builder.StringBuilder,
) -> #(Lexer, String) {
  case is_digit(l.ch) {
    // 48 is the ascii code for the character '0'
    // 57 is the ascii code for the character '9'
    True -> {
      let assert Ok(new_char) = bit_array.to_string(l.ch)
      read_number(read_char(l), sb |> string_builder.append(new_char))
    }
    _ -> {
      #(l, sb |> string_builder.to_string())
    }
  }
}

//TODO: Maybe find an alternative to returning tuples to avoid .0, .1 notation?
pub fn read_identifier(
  l: Lexer,
  sb: string_builder.StringBuilder,
) -> #(Lexer, String) {
  case is_letter_or_underscore(l.ch) {
    True -> {
      let assert Ok(new_char) = bit_array.to_string(l.ch)
      read_identifier(read_char(l), sb |> string_builder.append(new_char))
    }
    _ -> {
      #(l, sb |> string_builder.to_string())
    }
  }
}

pub fn peek_char(l: Lexer) -> BitArray {
  let longer_read_position = l.read_position >= string.length(l.input)
  case longer_read_position {
    True -> <<>>
    False ->
      string.slice(l.input, l.read_position, 1) |> bit_array.from_string()
  }
}

// WARNING: I don't know if tuples are how you're supposed to return multiple values, oh well :)
pub fn next_token(l: Lexer) -> #(Lexer, token.Token) {
  let trimmed_lex = skip_whitespace(l)
  let next_lex = read_char(trimmed_lex)
  case trimmed_lex.ch {
    <<"=":utf8>> ->
      //FIXME: THIS SHIT IS BROKEN, read_char is prob the culprit
      case peek_char(trimmed_lex) {
        <<"=":utf8>> -> #(
          read_char(next_lex),
          token.Token(token.TokenType(token.c_eq), "=="),
        )
        _ -> #(next_lex, token.Token(token.TokenType(token.c_assign), "="))
      }
    <<";":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_semicolon), ";"),
    )
    <<"(":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_lparen), "("),
    )
    <<")":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_rparen), ")"),
    )
    <<",":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_comma), ","),
    )
    <<"+":utf8>> -> #(next_lex, token.Token(token.TokenType(token.c_plus), "+"))
    <<"-":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_minus), "-"),
    )
    <<"!":utf8>> ->
      case peek_char(trimmed_lex) {
        <<"=":utf8>> -> #(
          read_char(next_lex),
          token.Token(token.TokenType(token.c_not_eq), "!="),
        )
        _ -> #(next_lex, token.Token(token.TokenType(token.c_bang), "!"))
      }
    <<"/":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_slash), "/"),
    )
    <<"*":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_asterisk), "*"),
    )
    <<"<":utf8>> -> #(next_lex, token.Token(token.TokenType(token.c_lt), "<"))
    <<">":utf8>> -> #(next_lex, token.Token(token.TokenType(token.c_gt), ">"))
    <<"{":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_lbrace), "{"),
    )
    <<"}":utf8>> -> #(
      next_lex,
      token.Token(token.TokenType(token.c_rbrace), "}"),
    )
    <<"":utf8>> -> #(next_lex, token.Token(token.TokenType(token.c_eof), ""))
    res ->
      case is_letter_or_underscore(res), is_digit(res) {
        True, _ -> {
          let result = read_identifier(trimmed_lex, string_builder.new())
          let str_token_type = token.lookup_ident(result.1)
          #(result.0, token.Token(token.TokenType(str_token_type), result.1))
        }
        _, True -> {
          let result = read_number(trimmed_lex, string_builder.new())
          #(result.0, token.Token(token.TokenType(token.c_int), result.1))
        }
        _, _ -> {
          let assert Ok(unknown_ch) = bit_array.to_string(trimmed_lex.ch)
          #(next_lex, token.Token(token.TokenType(token.c_illegal), unknown_ch))
        }
      }
  }
}
