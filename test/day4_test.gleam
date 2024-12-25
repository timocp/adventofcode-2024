import gleeunit
import gleeunit/should

import day4

pub fn main() {
  gleeunit.main()
}

const example1 = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"

pub fn part1_test() {
  day4.part1(example1) |> should.equal(18)
}

pub fn part2_test() {
  day4.part2(example1) |> should.equal(9)
}
