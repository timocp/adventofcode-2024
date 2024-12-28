import gleeunit
import gleeunit/should

import day9

pub fn main() {
  gleeunit.main()
}

const example1 = "2333133121414131402\n"

const example2 = "12345\n"

const example3 = "1313165\n"

pub fn part1_test() {
  day9.part1(example1) |> should.equal(1928)
  day9.part1(example2) |> should.equal(60)
}

pub fn part2_test() {
  day9.part2(example1) |> should.equal(2858)
  day9.part2(example3) |> should.equal(169)
}
