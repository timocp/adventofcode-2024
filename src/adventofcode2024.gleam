import argv
import gleam/int
import gleam/io
import gleam/list
import simplifile

import day1
import day2
import day3
import day4
import day5
import day6

pub fn main() {
  case argv.load().arguments {
    [arg] ->
      case int.parse(arg) {
        Ok(n) -> run(n)
        Error(_) -> io.println("Invalid day: " <> arg)
      }
    _ -> list.range(1, 6) |> list.each(fn(n) { run(n) })
  }
}

fn run(n: Int) -> Nil {
  let input = read_input(n)
  let output = fn(s) { "Day " <> int.to_string(n) <> " " <> s }
  io.print(output("Part 1: "))
  io.println(case n {
    1 -> day1.part1(input) |> int.to_string
    2 -> day2.part1(input) |> int.to_string
    3 -> day3.part1(input) |> int.to_string
    4 -> day4.part1(input) |> int.to_string
    5 -> day5.part1(input) |> int.to_string
    6 -> day6.part1(input) |> int.to_string
    _ -> "(not implemented)"
  })
  io.print(output("Part 2: "))
  io.println(case n {
    1 -> day1.part2(input) |> int.to_string
    2 -> day2.part2(input) |> int.to_string
    3 -> day3.part2(input) |> int.to_string
    4 -> day4.part2(input) |> int.to_string
    5 -> day5.part2(input) |> int.to_string
    6 -> day6.part2(input) |> int.to_string
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
