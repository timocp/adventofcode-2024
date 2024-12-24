import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result

pub fn part1(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(re, input)
  |> list.map(fn(match) {
    match.submatches
    |> list.map(fn(submatch) { option.unwrap(submatch, "") })
    |> list.filter_map(int.parse)
  })
  |> list.map(fn(mul) {
    mul |> list.reduce(fn(acc, m) { acc * m }) |> result.unwrap(0)
  })
  |> list.reduce(fn(acc, v) { acc + v })
  |> result.unwrap(0)
}
