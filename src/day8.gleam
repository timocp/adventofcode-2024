import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import grid.{type Pos}
import parse

pub fn part1(input: String) -> Int {
  let #(map, in_bounds) = parse_input(input)

  map
  |> dict.values
  |> list.flat_map(fn(antennas) { antinodes_for(antennas, in_bounds) })
  |> list.unique
  |> list.length
}

pub fn part2(input: String) -> Int {
  let #(map, in_bounds) = parse_input(input)

  map
  |> dict.values
  |> list.flat_map(fn(antennas) { harmonic_antinodes_for(antennas, in_bounds) })
  |> list.unique
  |> list.length
}

type BoundFn =
  fn(Pos) -> Bool

fn antinodes_for(antennas: List(Pos), in_bounds: BoundFn) -> List(Pos) {
  antennas
  |> list.combination_pairs
  |> list.flat_map(fn(pair) {
    [individual_antinode(pair.0, pair.1), individual_antinode(pair.1, pair.0)]
  })
  |> list.filter(in_bounds)
}

fn individual_antinode(a: Pos, b: Pos) -> Pos {
  let dx = a.0 - b.0
  let dy = a.1 - b.1
  #(a.0 + dx, a.1 + dy)
}

fn harmonic_antinodes_for(antennas: List(Pos), in_bounds: BoundFn) -> List(Pos) {
  antennas
  |> list.combination_pairs
  |> list.flat_map(fn(pair) {
    [
      find_harmonic_antinodes(pair.0, pair.1, in_bounds),
      find_harmonic_antinodes(pair.1, pair.0, in_bounds),
    ]
  })
  |> list.flatten
}

fn find_harmonic_antinodes(a: Pos, b: Pos, in_bounds: BoundFn) -> List(Pos) {
  let dx = a.0 - b.0
  let dy = a.1 - b.1

  next_harmonic_antinode(a, dx, dy, in_bounds, [a])
}

fn next_harmonic_antinode(
  a: Pos,
  dx: Int,
  dy: Int,
  in_bounds: BoundFn,
  nodes: List(Pos),
) -> List(Pos) {
  let node = #(a.0 + dx, a.1 + dy)
  case in_bounds(node) {
    True -> next_harmonic_antinode(node, dx, dy, in_bounds, [node, ..nodes])
    False -> nodes
  }
}

fn parse_input(input: String) -> #(Dict(String, List(Pos)), BoundFn) {
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

  let in_bounds = fn(p: Pos) {
    p.0 >= 0 && p.0 < width && p.1 >= 0 && p.1 < height
  }

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
    in_bounds,
  )
}
