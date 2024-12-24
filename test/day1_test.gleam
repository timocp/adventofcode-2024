import gleeunit
import gleeunit/should

import day1

pub fn main() {
  gleeunit.main()
}

const example1 = "3   4
4   3
2   5
1   3
3   9
3   3
"

pub fn part1_test() {
  day1.part1(example1) |> should.equal(11)
}
