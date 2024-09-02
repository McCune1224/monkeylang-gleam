pub const c_illegal = "ILLEGAL"

pub const c_eof = "EOF"

pub const c_ident = "IDENT"

pub const c_int = "INT"

pub const c_assign = "="

pub const c_plus = "+"

pub const c_minus = "-"

pub const c_bang = "!"

pub const c_asterisk = "*"

pub const c_slash = "/"

pub const c_lt = "<"

pub const c_gt = ">"

pub const c_comma = ","

pub const c_semicolon = ";"

pub const c_lparen = "("

pub const c_rparen = ")"

pub const c_lbrace = "{"

pub const c_rbrace = "}"

pub const c_function = "FUNCTION"

pub const c_let = "LET"

pub const c_true = "TRUE"

pub const c_false = "FALSE"

pub const c_eq = "=="

pub const c_not_eq = "!="

pub const c_if = "IF"

pub const c_else = "ELSE"

pub const c_return = "RETURN"

pub type TokenType {
  TokenType(String)
}

pub type Token {
  Token(token_type: TokenType, literal: String)
}

pub fn lookup_ident(s: String) -> String {
  case s {
    "fn" -> c_function
    "let" -> c_let
    "true" -> c_true
    "false" -> c_false
    "if" -> c_if
    "else" -> c_else
    "return" -> c_return

    _ -> c_ident
  }
}
