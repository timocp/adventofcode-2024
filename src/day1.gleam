import gleam/int
import gleam/list
import gleam/string

import tote/bag

pub fn part1(input: String) -> Int {
  let #(left, right) = parse_input(input)
  list.zip(left, right)
  |> list.fold(0, fn(acc, pair) { acc + int.absolute_value(pair.0 - pair.1) })
}

pub fn part2(input: String) -> Int {
  let #(left, right) = parse_input(input)
  let left_count = bag.from_list(left)
  right
  |> list.map(fn(r) { r * bag.copies(left_count, r) })
  |> list.fold(0, fn(acc, r) { acc + r })
}

fn parse_input(input: String) -> #(List(Int), List(Int)) {
  let data =
    input
    |> string.split("\n")
    |> list.filter(fn(line) { line != "" })
    |> list.map(fn(line) {
      line |> string.split(" ") |> list.filter_map(fn(str) { int.parse(str) })
    })
  #(
    data |> list.filter_map(list.first) |> list.sort(by: int.compare),
    data |> list.filter_map(list.last) |> list.sort(by: int.compare),
  )
}
