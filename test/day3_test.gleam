import gleeunit
import gleeunit/should

import day3

pub fn main() {
  gleeunit.main()
}

const example1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))\n"

pub fn part1_test() {
  day3.part1(example1) |> should.equal(161)
}
