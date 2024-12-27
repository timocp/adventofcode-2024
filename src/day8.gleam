import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import grid.{type Pos}
import parse

pub fn part1(input: String) -> Int {
  let #(antennas, width, height) = parse_input(input)

  antennas
  |> dict.keys
  |> list.flat_map(fn(label) { antinodes_for(antennas, label, width, height) })
  |> list.unique
  |> list.length
}

fn antinodes_for(
  antennas: Dict(String, List(Pos)),
  label: String,
  width: Int,
  height: Int,
) -> List(Pos) {
  antennas
  |> dict.get(label)
  |> result.unwrap([])
  |> list.combination_pairs
  |> list.flat_map(fn(pair) {
    [individual_antinode(pair.0, pair.1), individual_antinode(pair.1, pair.0)]
  })
  |> list.filter(fn(pos) {
    pos.0 >= 0 && pos.0 < width && pos.1 >= 0 && pos.1 < height
  })
}

fn individual_antinode(a: Pos, b: Pos) -> Pos {
  let dx = a.0 - b.0
  let dy = a.1 - b.1
  #(a.0 + dx, a.1 + dy)
}

fn parse_input(input: String) -> #(Dict(String, List(Pos)), Int, Int) {
  let lines = parse.lines(input)

  let pos_to_char =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
      |> list.filter(fn(poschar) { poschar.1 != "." })
    })
    |> list.flatten
    |> dict.from_list

  let width = lines |> list.first |> result.unwrap("") |> string.length
  let height = lines |> list.length

  #(
    pos_to_char
      |> dict.values
      |> list.unique
      |> list.map(fn(char) {
        #(
          char,
          pos_to_char
            |> dict.to_list
            |> list.filter_map(fn(poschar) {
              case poschar.1 == char {
                True -> Ok(poschar.0)
                False -> Error(Nil)
              }
            }),
        )
      })
      |> dict.from_list,
    width,
    height,
  )
}
