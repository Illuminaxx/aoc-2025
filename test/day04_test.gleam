import day04
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn example_part1_test() {
  let input =
    "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

  day04.solve_part1(input)
  |> should.equal(13)
}

pub fn example_part2_test() {
  let input =
    "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

  day04.solve_part2(input)
  |> should.equal(43)
}
