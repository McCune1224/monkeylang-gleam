import gleam/int

pub const c_illegal = "ILLEGAL"

pub const c_eof = "EOF"

pub const c_ident = "IDENT"

pub const c_int = "INT"

pub const c_assign = "="

pub const c_plus = "+"

pub const c_comma = ","

pub const c_semicolon = ";"

pub const c_lparen = "("

pub const c_rparen = ")"

pub const c_lbrace = "{"

pub const c_rbrace = "}"

pub const c_function = "FUNCTION"

pub const c_let = "LET"

pub type TokenType {
  TokenType(String)
}

pub type Token {
  Token(token_type: TokenType, literal: String)
}
