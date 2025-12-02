import day01
import day02
import fs
import gleam/int
import gleam/io

pub fn main() {
  // Day 1
  case fs.read("input.txt") {
    Ok(contents) -> {
      let count_part1 = day01.count_hits_part1(contents)
      io.println(
        "Day 1 Part 1 - Number of times dial ends on 0: "
        <> int.to_string(count_part1),
      )

      let count_part2 = day01.count_hits_part2(contents)
      io.println(
        "Day 1 Part 2 - Number of times dial hits 0: "
        <> int.to_string(count_part2),
      )
    }
    Error(reason) -> {
      io.println("Day 1 error: " <> reason)
    }
  }

  // Day 2
  case fs.read("input2.txt") {
    Ok(contents) -> {
      let sum_part1 = day02.solve_part1(contents)
      io.println(
        "Day 2 Part 1 - Sum of invalid IDs: " <> int.to_string(sum_part1),
      )

      let sum_part2 = day02.solve_part2(contents)
      io.println(
        "Day 2 Part 2 - Sum of invalid IDs: " <> int.to_string(sum_part2),
      )
    }
    Error(reason) -> {
      io.println("Day 2 error: " <> reason)
    }
  }
}
