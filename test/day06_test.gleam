import day06
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn example_part1_test() {
  let input =
    "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

  day06.solve_part1(input)
  |> should.equal(4_277_556)
}

pub fn example_part2_test() {
  let input =
    "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

  day06.solve_part2(input)
  |> should.equal(3_263_827)
}

pub fn solve_problem_add_test() {
  let problem = day06.Problem([328, 64, 98], day06.Add)
  day06.solve_problem(problem)
  |> should.equal(490)
}

pub fn solve_problem_multiply_test() {
  let problem = day06.Problem([123, 45, 6], day06.Multiply)
  day06.solve_problem(problem)
  |> should.equal(33_210)
}
