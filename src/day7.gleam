import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import parse

pub fn part1(input: String) -> Int {
  solve(input, [Add, Multiply])
}

pub fn part2(input: String) -> Int {
  solve(input, [Add, Multiply, Concatenate])
}

fn solve(input: String, operations: List(Op)) -> Int {
  let valid = fn(e: #(Int, List(Op))) { is_valid(e, operations) }

  input
  |> parse_input
  |> list.filter(valid)
  |> list.map(pair.first)
  |> int.sum
}

pub type Op {
  Number(Int)
  Add
  Multiply
  Concatenate
}

fn evaluate(ops: List(Op)) -> Int {
  ops |> list.reverse |> forward_evaluate
}

fn forward_evaluate(ops: List(Op)) -> Int {
  case ops {
    [Number(a), Add, ..rest] -> a + forward_evaluate(rest)
    [Number(a), Multiply, ..rest] -> a * forward_evaluate(rest)
    [Number(a), Concatenate, ..rest] -> {
      a
      |> int.digits(10)
      |> result.unwrap([])
      |> list.fold(forward_evaluate(rest), fn(acc, digit) { acc * 10 + digit })
    }
    [Number(a)] -> a
    _ -> panic as { "Invalid expression" }
  }
}

fn is_valid(equation: #(Int, List(Op)), operations: List(Op)) -> Bool {
  possible_ops(equation.1, operations)
  |> list.find(fn(ops) { evaluate(ops) == equation.0 })
  |> result.is_ok
}

fn possible_ops(ops: List(Op), operations: List(Op)) -> List(List(Op)) {
  case ops {
    [Number(a)] -> [[Number(a)]]
    [Number(a), ..rest] -> {
      possible_ops(rest, operations)
      |> list.flat_map(fn(restops) {
        operations
        |> list.map(fn(new_op) { [Number(a), new_op, ..restops] })
      })
    }
    [] -> []
    _ -> panic as "possible_ops() requires numeric operands only"
  }
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
