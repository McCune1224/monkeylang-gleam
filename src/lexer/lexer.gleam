import gleam/list
import gleam/string

pub type Lexer {
  // WARNING: ch should be used to represent an 8-bit char, not sure if just slapping it as an Int is good...
  Lexer(input: String, position: Int, read_position: Int, ch: Int)
}

fn get_char_codepoint(s: String, index: Int) -> Int {
  case
    string.slice(s, index, 1)
    |> string.to_utf_codepoints()
    |> list.first
  {
    Ok(result) -> string.utf_codepoint_to_int(result)
    _ -> 32
    //default to whitespace utf
  }
}

pub fn read_char(l: Lexer) -> Lexer {
  case l.read_position >= string.length(l.input) {
    True -> Lexer(l.input, l.read_position, l.position + 1, 0)
    _ ->
      Lexer(
        l.input,
        l.read_position,
        l.position + 1,
        get_char_codepoint(l.input, l.read_position),
      )
  }
}
