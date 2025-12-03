import day03
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// ============ PART 1 TESTS ============
pub fn max_joltage_part1_987654321111111_test() {
  day03.max_joltage_part_one("987654321111111")
  |> should.equal(98)
}

pub fn max_joltage_part1_811111111111119_test() {
  day03.max_joltage_part_one("811111111111119")
  |> should.equal(89)
}

pub fn max_joltage_part1_234234234234278_test() {
  day03.max_joltage_part_one("234234234234278")
  |> should.equal(78)
}

pub fn max_joltage_part1_818181911112111_test() {
  day03.max_joltage_part_one("818181911112111")
  |> should.equal(92)
}

pub fn example_part1_test() {
  let input =
    "987654321111111
811111111111119
234234234234278
818181911112111"

  day03.solve_part_one(input)
  |> should.equal(357)
}

// ============ PART 2 TESTS ============
pub fn max_joltage_part2_987654321111111_test() {
  day03.max_joltage_part_two("987654321111111", 12)
  |> should.equal(987_654_321_111)
}

pub fn max_joltage_part2_811111111111119_test() {
  day03.max_joltage_part_two("811111111111119", 12)
  |> should.equal(811_111_111_119)
}

pub fn max_joltage_part2_234234234234278_test() {
  day03.max_joltage_part_two("234234234234278", 12)
  |> should.equal(434_234_234_278)
}

pub fn max_joltage_part2_818181911112111_test() {
  day03.max_joltage_part_two("818181911112111", 12)
  |> should.equal(888_911_112_111)
}

pub fn example_part2_test() {
  let input =
    "987654321111111
811111111111119
234234234234278
818181911112111"

  day03.solve_part_two(input)
  |> should.equal(3_121_910_778_619)
}
