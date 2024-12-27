import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import parse

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> list.filter(is_valid)
  |> list.map(pair.first)
  |> int.sum
}

pub type Op {
  Number(Int)
  Add
  Multiply
}

fn evaluate(ops: List(Op)) -> Int {
  ops |> list.reverse |> forward_evaluate
}

fn forward_evaluate(ops: List(Op)) -> Int {
  case ops {
    [Number(a), Add, ..rest] -> a + forward_evaluate(rest)
    [Number(a), Multiply, ..rest] -> a * forward_evaluate(rest)
    [Number(a)] -> a
    _ -> panic as { "Invalid expression" }
  }
}

fn is_valid(equation: #(Int, List(Op))) -> Bool {
  let _debug_equation = fn(ops: List(Op)) {
    io.println_error("")
    io.println_error(
      "checking if "
      <> int.to_string(equation.0)
      <> " == "
      <> debug_ops(ops)
      <> case evaluate(ops) == equation.0 {
        True -> " (yes!)"
        False -> " (no, " <> int.to_string(evaluate(ops)) <> ")"
      },
    )
    ops
  }

  possible_ops(equation.1)
  // |> list.map(debug_equation)
  |> list.find(fn(ops) { evaluate(ops) == equation.0 })
  |> result.is_ok
}

fn possible_ops(ops: List(Op)) -> List(List(Op)) {
  case ops {
    [Number(a)] -> [[Number(a)]]
    [Number(a), ..rest] -> {
      possible_ops(rest)
      |> list.flat_map(fn(restops) {
        [[Number(a), Add, ..restops], [Number(a), Multiply, ..restops]]
      })
    }
    [] -> []
    [Add, ..] | [Multiply, ..] ->
      panic as "possible_ops() requires numeric operands only"
  }
}

fn debug_ops(ops: List(Op)) -> String {
  ops
  |> list.map(fn(op) {
    case op {
      Number(a) -> int.to_string(a)
      Add -> "+"
      Multiply -> "*"
    }
  })
  |> string.join(" ")
}

fn parse_input(input: String) -> List(#(Int, List(Op))) {
  input
  |> parse.lines
  |> list.map(fn(line) {
    line |> string.split_once(": ") |> result.unwrap(#("0", "0"))
  })
  |> list.map(fn(row) {
    #(
      row.0 |> int.parse |> result.unwrap(0),
      row.1
        |> string.split(" ")
        |> list.filter_map(int.parse)
        |> list.map(fn(i) { Number(i) }),
    )
  })
}
