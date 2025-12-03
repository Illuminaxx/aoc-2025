import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub fn max_joltage_part_one(bank: String) -> Int {
  let digits = string.to_graphemes(bank)
  let len = list.length(digits)

  find_max_pair_all(digits, len, 0, 0)
}

fn find_max_pair_all(
  digits: List(String),
  len: Int,
  i: Int,
  current_max: Int,
) -> Int {
  case i >= len - 1 {
    True -> current_max
    False -> {
      let max_from_i = find_pairs_from_i(digits, i, i + 1, current_max)
      find_max_pair_all(digits, len, i + 1, max_from_i)
    }
  }
}

fn find_pairs_from_i(
  digits: List(String),
  i: Int,
  j: Int,
  current_max: Int,
) -> Int {
  case j >= list.length(digits) {
    True -> current_max
    False -> {
      let first = list_at(digits, i)
      let second = list_at(digits, j)

      case first, second {
        Some(f), Some(s) -> {
          let two_digit = f <> s
          case int.parse(two_digit) {
            Ok(value) -> {
              let new_max = case value > current_max {
                True -> value
                False -> current_max
              }
              find_pairs_from_i(digits, i, j + 1, new_max)
            }
            Error(_) -> find_pairs_from_i(digits, i, j + 1, current_max)
          }
        }
        _, _ -> find_pairs_from_i(digits, i, j + 1, current_max)
      }
    }
  }
}

fn list_at(lst: List(String), index: Int) -> Option(String) {
  case index {
    0 ->
      case lst {
        [first, ..] -> Some(first)
        [] -> None
      }
    _ ->
      case lst {
        [_, ..rest] -> list_at(rest, index - 1)
        [] -> None
      }
  }
}

pub fn max_joltage_part_two(bank: String, k: Int) -> Int {
  let digits = string.to_graphemes(bank)
  let result = largest_subsequence(digits, k)
  let number_str = string.join(result, "")

  case int.parse(number_str) {
    Ok(n) -> n
    Error(_) -> 0
  }
}

fn largest_subsequence(digits: List(String), k: Int) -> List(String) {
  let n = list.length(digits)
  case k > n {
    True -> digits
    False -> build_largest(digits, k, [])
  }
}

fn build_largest(
  remaining: List(String),
  needed: Int,
  acc: List(String),
) -> List(String) {
  case needed {
    0 -> list.reverse(acc)
    _ -> {
      let available = list.length(remaining)
      case available < needed {
        True -> list.reverse(acc)
        False -> {
          let window_size = available - needed + 1
          let window = list.take(remaining, window_size)

          case find_max_in_window(window, 0, None, 0) {
            #(max_digit, max_index) -> {
              let new_remaining = list.drop(remaining, max_index + 1)
              build_largest(new_remaining, needed - 1, [max_digit, ..acc])
            }
          }
        }
      }
    }
  }
}

fn find_max_in_window(
  window: List(String),
  index: Int,
  max_digit: Option(String),
  max_index: Int,
) -> #(String, Int) {
  case window {
    [] ->
      case max_digit {
        Some(d) -> #(d, max_index)
        None -> #("0", 0)
      }
    [digit, ..rest] -> {
      case max_digit {
        None -> find_max_in_window(rest, index + 1, Some(digit), index)
        Some(current_max) -> {
          case int.parse(digit), int.parse(current_max) {
            Ok(d), Ok(m) -> {
              case d > m {
                True -> find_max_in_window(rest, index + 1, Some(digit), index)
                False ->
                  find_max_in_window(
                    rest,
                    index + 1,
                    Some(current_max),
                    max_index,
                  )
              }
            }
            _, _ ->
              find_max_in_window(rest, index + 1, Some(current_max), max_index)
          }
        }
      }
    }
  }
}

// Solve part one
pub fn solve_part_one(input: String) -> Int {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  list.fold(lines, 0, fn(acc, line) {
    let trimmed = string.trim(line)
    acc + max_joltage_part_one(trimmed)
  })
}

// Solve part 2
pub fn solve_part_two(input: String) -> Int {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  list.fold(lines, 0, fn(acc, line) {
    let trimmed = string.trim(line)
    acc + max_joltage_part_two(trimmed, 12)
  })
}
