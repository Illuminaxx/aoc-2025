import gleeunit
import gleeunit/should
import day01

pub fn main() {
  gleeunit.main()
}

pub fn example_part1_test() {
  let input = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"
  
  day01.count_hits_part1(input)
  |> should.equal(3)
}

pub fn example_part2_test() {
  let input = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"
  
  day01.count_hits_part2(input)
  |> should.equal(6)
}