import gleam/int
import gleam/io

import simplifile

import day1

pub fn main() {
  run(1)
}

fn run(n: Int) -> Nil {
  let input = read_input(n)
  io.print("Day " <> int.to_string(n) <> " Part 1: ")
  io.println(int.to_string(day1.part1(input)))
  io.print("Day " <> int.to_string(n) <> " Part 2: ")
  io.println(int.to_string(day1.part2(input)))
}

fn read_input(n: Int) -> String {
  let filename = "input/day" <> int.to_string(n) <> ".txt"
  case simplifile.read(from: filename) {
    Ok(data) -> data
    Error(_data) ->
      panic as { "Input data missing for day " <> int.to_string(n) }
  }
}
