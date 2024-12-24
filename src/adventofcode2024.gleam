import gleam/int
import gleam/io
import gleam/list

import argv
import simplifile

import day1
import day2

pub fn main() {
  case argv.load().arguments {
    [arg] ->
      case int.parse(arg) {
        Ok(n) -> run(n)
        Error(_) -> io.println("Invalid day: " <> arg)
      }
    _ -> list.range(1, 2) |> list.each(fn(n) { run(n) })
  }
}

fn run(n: Int) -> Nil {
  let input = read_input(n)
  let output = fn(s) { "Day " <> int.to_string(n) <> " " <> s }
  io.print(output("Part 1: "))
  io.println(case n {
    1 -> day1.part1(input) |> int.to_string
    2 -> day2.part1(input) |> int.to_string
    _ -> "(not implemented)"
  })
  io.print(output("Part 2: "))
  io.println(case n {
    1 -> day1.part2(input) |> int.to_string
    2 -> day2.part2(input) |> int.to_string
    _ -> "(not implemented)"
  })
}

fn read_input(n: Int) -> String {
  let filename = "input/day" <> int.to_string(n) <> ".txt"
  case simplifile.read(from: filename) {
    Ok(data) -> data
    Error(_data) ->
      panic as { "Input data missing for day " <> int.to_string(n) }
  }
}
