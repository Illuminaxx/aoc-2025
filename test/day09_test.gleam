import day09
import gleeunit/should

pub fn example_part1_test() {
  let input =
    "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

  day09.solve_part1(input)
  |> should.equal(50)
}

pub fn example_part2_test() {
  let input =
    "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

  day09.solve_part2(input)
  |> should.equal(24)
}
