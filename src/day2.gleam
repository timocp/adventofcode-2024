import gleam/int
import gleam/list
import gleam/string

import parse

pub fn part1(input: String) -> Int {
  input |> parse_input |> list.count(safe)
}

pub fn part2(input: String) -> Int {
  input |> parse_input |> list.count(safe_enough)
}

fn safe(report: List(Int)) -> Bool {
  increasing(report) || decreasing(report)
}

fn safe_enough(report: List(Int)) -> Bool {
  safe(report)
  || list.range(0, list.length(report) - 1)
  |> list.any(fn(i) {
    let partition = list.split(report, i)
    safe(list.flatten([partition.0, list.drop(partition.1, 1)]))
  })
}

fn increasing(report: List(Int)) -> Bool {
  case report {
    [first, second, ..rest] ->
      second > first && second - first <= 3 && increasing([second, ..rest])
    _ -> True
  }
}

fn decreasing(report: List(Int)) -> Bool {
  case report {
    [first, second, ..rest] ->
      second < first && first - second <= 3 && decreasing([second, ..rest])
    _ -> True
  }
}

fn parse_input(input: String) -> List(List(Int)) {
  parse.lines(input)
  |> list.map(fn(line) {
    line |> string.split(" ") |> list.filter_map(fn(str) { int.parse(str) })
  })
}
