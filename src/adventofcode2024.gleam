import argv
import birl
import birl/duration
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8

pub fn main() {
  case argv.load().arguments {
    [arg] ->
      case int.parse(arg) {
        Ok(d) -> run(d)
        Error(_) -> io.println("Invalid day: " <> arg)
      }
    _ -> list.range(1, 8) |> list.each(fn(d) { run(d) })
  }
}

fn run(d: Int) -> Nil {
  let input = read_input(d)
  run_part(d, 1, fn() {
    case d {
      1 -> day1.part1(input) |> int.to_string
      2 -> day2.part1(input) |> int.to_string
      3 -> day3.part1(input) |> int.to_string
      4 -> day4.part1(input) |> int.to_string
      5 -> day5.part1(input) |> int.to_string
      6 -> day6.part1(input) |> int.to_string
      7 -> day7.part1(input) |> int.to_string
      8 -> day8.part1(input) |> int.to_string
      _ -> "(not implemented)"
    }
  })
  run_part(d, 2, fn() {
    case d {
      1 -> day1.part2(input) |> int.to_string
      2 -> day2.part2(input) |> int.to_string
      3 -> day3.part2(input) |> int.to_string
      4 -> day4.part2(input) |> int.to_string
      5 -> day5.part2(input) |> int.to_string
      6 -> day6.part2(input) |> int.to_string
      7 -> day7.part2(input) |> int.to_string
      8 -> day8.part2(input) |> int.to_string
      _ -> "(not implemented)"
    }
  })
}

fn run_part(d: Int, p: Int, f: fn() -> String) {
  io.print(
    "Day "
    <> string.pad_start(int.to_string(d), 2, " ")
    <> " Part "
    <> int.to_string(p)
    <> ": ",
  )
  let t0 = birl.now()
  let result = f()
  let ms =
    birl.now()
    |> birl.difference(t0)
    |> duration.blur_to(duration.MilliSecond)
    |> int.to_string
  // TODO: multiline results
  io.println("[" <> string.pad_start(ms, 4, " ") <> "ms] " <> result)
}

fn read_input(n: Int) -> String {
  let filename = "input/day" <> int.to_string(n) <> ".txt"
  case simplifile.read(from: filename) {
    Ok(data) -> data
    Error(_data) ->
      panic as { "Input data missing for day " <> int.to_string(n) }
  }
}
