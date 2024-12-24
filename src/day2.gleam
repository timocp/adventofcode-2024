import gleam/int
import gleam/list
import gleam/string

pub fn part1(input: String) -> Int {
  input |> parse_input |> list.count(safe)
}

fn safe(report: List(Int)) -> Bool {
  increasing(report) || decreasing(report)
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
  input
  |> string.split("\n")
  |> list.filter(fn(line) { line != "" })
  |> list.map(fn(line) {
    line |> string.split(" ") |> list.filter_map(fn(str) { int.parse(str) })
  })
}
