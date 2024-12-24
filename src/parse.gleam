import gleam/string

pub fn lines(input: String) -> List(String) {
  input |> string.trim_end |> string.split("\n")
}
