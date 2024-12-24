import gleam/dict
import gleam/list
import gleam/string

pub fn lines(input: String) -> List(String) {
  input |> string.trim_end |> string.split("\n")
}

// Because no arrays, grid is a dictionary with keys #(x, y)
type Grid =
  dict.Dict(#(Int, Int), String)

pub fn grid(input: String) -> Grid {
  input
  |> lines
  |> list.index_map(fn(line, y) {
    line |> string.split("") |> list.index_map(fn(cell, x) { #(#(x, y), cell) })
  })
  |> list.flatten
  |> dict.from_list
}
