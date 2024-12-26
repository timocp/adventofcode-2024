import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

pub fn part1(input: String) -> Int {
  let #(compare, updates) = parse_input(input)

  updates
  |> list.filter(fn(pages) { is_sorted(pages, compare) })
  |> list.map(middle_page)
  |> int.sum
}

fn is_sorted(pages: List(Int), compare: fn(Int, Int) -> order.Order) -> Bool {
  pages == pages |> list.sort(compare)
}

fn middle_page(pages: List(Int)) -> Int {
  let mid = list.length(pages) / 2

  pages |> list.drop(mid) |> list.first |> result.unwrap(0)
}

fn parse_input(input: String) -> #(fn(Int, Int) -> order.Order, List(List(Int))) {
  let #(section1, section2) =
    input
    |> string.trim_end
    |> string.split_once("\n\n")
    |> result.unwrap(#("", ""))

  #(parse_rules(section1), parse_updates(section2))
}

fn parse_rules(input: String) -> fn(Int, Int) -> order.Order {
  let rules =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      line |> string.split("|") |> list.filter_map(int.parse)
    })
    |> list.map(fn(rule) {
      #(
        list.first(rule) |> result.unwrap(0),
        list.last(rule) |> result.unwrap(0),
      )
    })

  fn(a: Int, b: Int) -> order.Order {
    case
      rules
      |> list.find(fn(rule) { rule == #(a, b) || rule == #(b, a) })
    {
      Ok(rule) -> {
        case a == rule.0 {
          True -> order.Lt
          False -> order.Gt
        }
      }
      Error(_) -> order.Eq
    }
  }
}

fn parse_updates(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line |> string.split(",") |> list.filter_map(int.parse)
  })
}
