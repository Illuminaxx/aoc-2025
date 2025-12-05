import gleeunit
import gleeunit/should
import day05

pub fn main() {
  gleeunit.main()
}

pub fn example_part1_test() {
  let input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"
  
  day05.solve_part1(input)
  |> should.equal(3)
}

pub fn example_part2_test() {
  let input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"
  
  day05.solve_part2(input)
  |> should.equal(14)
}

pub fn is_in_range_test() {
  let range = day05.Range(3, 5)
  day05.is_in_range(3, range) |> should.be_true()
  day05.is_in_range(4, range) |> should.be_true()
  day05.is_in_range(5, range) |> should.be_true()
  day05.is_in_range(2, range) |> should.be_false()
  day05.is_in_range(6, range) |> should.be_false()
}