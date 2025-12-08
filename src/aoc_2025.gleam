import day01
import day02
import day03
import day04
import day05
import day06
import day07
import fs
import gleam/int
import gleam/io

pub fn main() {
  // Day 1
  case fs.read("input.txt") {
    Ok(contents) -> {
      let count_part1 = day01.count_hits_part1(contents)
      io.println(
        "Day 1 part 1 - Number of times dial ends on 0: "
        <> int.to_string(count_part1),
      )

      let count_part2 = day01.count_hits_part2(contents)
      io.println(
        "Day 1 part 2 - Number of times dial hits 0: "
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
        "Day 2 part 1 - Sum of invalid IDs: " <> int.to_string(sum_part1),
      )

      let sum_part2 = day02.solve_part2(contents)
      io.println(
        "Day 2 part 2 - Sum of invalid IDs: " <> int.to_string(sum_part2),
      )
    }
    Error(reason) -> {
      io.println("Day 2 error: " <> reason)
    }
  }

  // Day 3
  case fs.read("input3.txt") {
    Ok(contents) -> {
      let joltage_part_one = day03.solve_part_one(contents)
      io.println(
        "Day 3 part 1 - Joltage Total: " <> int.to_string(joltage_part_one),
      )
      let joltage_part_two = day03.solve_part_two(contents)
      io.println(
        "Day 3 part 2 - Joltage Total: " <> int.to_string(joltage_part_two),
      )
    }
    Error(reason) -> {
      io.println("Day 3 error: " <> reason)
    }
  }

  // Day 4
  case fs.read("input4.txt") {
    Ok(contents) -> {
      let rolls = day04.solve_part1(contents)
      io.println("Day 4 part 1 - Printing : " <> int.to_string(rolls))
      let removed_rolls = day04.solve_part2(contents)
      io.println(
        "Day 4 part 2 - Removed rolls: " <> int.to_string(removed_rolls),
      )
    }
    Error(reason) -> {
      io.println("Day 4 error: " <> reason)
    }
  }

  // Day 5
  case fs.read("input5.txt") {
    Ok(contents) -> {
      let fresh_count = day05.solve_part1(contents)
      io.println(
        "Day 5 part 1 - Fresh ingredients: " <> int.to_string(fresh_count),
      )
      let all_fresh_ingredients = day05.solve_part2(contents)
      io.println(
        "Day 5 part 2 - All Fresh ingredients: "
        <> int.to_string(all_fresh_ingredients),
      )
    }
    Error(reason) -> {
      io.println("Day 5 error: " <> reason)
    }
  }

  // Day 6 
  case fs.read("input6.txt") {
    Ok(contents) -> {
      let trash_compacted = day06.solve_part1(contents)
      io.println(
        "Day 6 part 1 - Trash compactor Total: "
        <> int.to_string(trash_compacted),
      )
      let total_rtl = day06.solve_part2(contents)
      io.println(
        "Day 6 Part 2 - Grand total (RTL): " <> int.to_string(total_rtl),
      )
    }
    Error(reason) -> {
      io.println("Day 6 error: " <> reason)
    }
  }

  case fs.read("input7.txt") {
    Ok(contents) -> {
      let splits = day07.solve_part1(contents)
      io.println("Day 7 part 1 - Beam splits: " <> int.to_string(splits))
      let timelines = day07.solve_part2(contents)
      io.println("Day 7 Part 2 - Timelines: " <> int.to_string(timelines))
    }
    Error(reason) -> {
      io.println("Day 7 error: " <> reason)
    }
  }
}
