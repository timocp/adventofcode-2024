import gleeunit
import gleeunit/should

import day6

pub fn main() {
  gleeunit.main()
}

const example1 = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

pub fn part1_test() {
  day6.part1(example1) |> should.equal(41)
}

pub fn part2_test() {
  day6.part2(example1) |> should.equal(6)
}
