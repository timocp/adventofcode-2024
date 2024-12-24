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

pub fn part2(input: String) -> Int {
  input |> parse_input |> process(True)
}

fn process(input: List(Token), doing: Bool) -> Int {
  let #(head, tail) = list.split(input, 1)
  case list.first(head) {
    Ok(token) ->
      case token {
        Do -> process(tail, True)
        Dont -> process(tail, False)
        Mul(a, b) ->
          process(tail, doing)
          + case doing {
            True -> a * b
            False -> 0
          }
      }
    Error(_) -> 0
  }
}

type Token {
  Mul(a: Int, b: Int)
  Do
  Dont
}

fn parse_input(input: String) -> List(Token) {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
  regexp.scan(re, input)
  |> list.map(fn(match) {
    case match.content {
      "do()" -> Do
      "don't()" -> Dont
      _ -> {
        // unwrap are safe due to regex, these are mul\(\d+,\d+\)
        let values =
          match.submatches
          |> list.map(fn(submatch) { option.unwrap(submatch, "") })
          |> list.filter_map(int.parse)
        Mul(
          values |> list.first |> result.unwrap(0),
          values |> list.drop(1) |> list.first |> result.unwrap(0),
        )
      }
    }
  })
}
