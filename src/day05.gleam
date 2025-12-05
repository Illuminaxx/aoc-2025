// src/day05.gleam
import gleam/int
import gleam/list
import gleam/string

pub type Range {
  Range(Int, Int)
}

pub fn parse_input(input: String) -> #(List(Range), List(Int)) {
  let normalized = string.replace(input, "\r\n", "\n")

  let parts =
    normalized
    |> string.trim
    |> string.split("\n\n")

  case parts {
    [ranges_str, ids_str] -> {
      let ranges = parse_ranges(ranges_str)
      let ids = parse_ids(ids_str)
      #(ranges, ids)
    }
    _ -> split_on_empty_line(normalized)
  }
}

fn split_on_empty_line(input: String) -> #(List(Range), List(Int)) {
  let lines = string.split(input, "\n")
  let #(ranges_lines, ids_lines) = split_at_empty(lines, [])

  let ranges = list.filter_map(ranges_lines, parse_range)
  let ids =
    list.filter_map(ids_lines, fn(line) { int.parse(string.trim(line)) })

  #(ranges, ids)
}

fn split_at_empty(
  lines: List(String),
  before: List(String),
) -> #(List(String), List(String)) {
  case lines {
    [] -> #(list.reverse(before), [])
    [line, ..rest] -> {
      case string.trim(line) {
        "" -> #(list.reverse(before), rest)
        _ -> split_at_empty(rest, [line, ..before])
      }
    }
  }
}

fn parse_ranges(input: String) -> List(Range) {
  input
  |> string.split("\n")
  |> list.filter_map(parse_range)
}

fn parse_range(line: String) -> Result(Range, Nil) {
  let trimmed = string.trim(line)
  case trimmed {
    "" -> Error(Nil)
    _ ->
      case string.split(trimmed, "-") {
        [start_str, end_str] -> {
          case int.parse(start_str), int.parse(end_str) {
            Ok(start), Ok(end) -> Ok(Range(start, end))
            _, _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
  }
}

fn parse_ids(input: String) -> List(Int) {
  input
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    let trimmed = string.trim(line)
    case trimmed {
      "" -> Error(Nil)
      _ -> int.parse(trimmed)
    }
  })
}

pub fn is_in_range(id: Int, range: Range) -> Bool {
  let Range(start, end) = range
  id >= start && id <= end
}

fn is_fresh(id: Int, ranges: List(Range)) -> Bool {
  list.any(ranges, fn(range) { is_in_range(id, range) })
}

pub fn count_fresh(input: String) -> Int {
  let #(ranges, ids) = parse_input(input)
  list.count(ids, fn(id) { is_fresh(id, ranges) })
}

fn merge_ranges(ranges: List(Range)) -> List(Range) {
  let sorted =
    list.sort(ranges, fn(a, b) {
      let Range(a_start, _) = a
      let Range(b_start, _) = b
      int.compare(a_start, b_start)
    })

  merge_sorted(sorted, [])
}

fn merge_sorted(ranges: List(Range), acc: List(Range)) -> List(Range) {
  case ranges {
    [] -> list.reverse(acc)
    [first, ..rest] -> {
      case acc {
        [] -> merge_sorted(rest, [first])
        [last, ..prev] -> {
          let Range(last_start, last_end) = last
          let Range(first_start, first_end) = first

          
          case first_start <= last_end + 1 {
            True -> {
              
              let new_end = int.max(last_end, first_end)
              let merged = Range(last_start, new_end)
              merge_sorted(rest, [merged, ..prev])
            }
            False -> {
              
              merge_sorted(rest, [first, last, ..prev])
            }
          }
        }
      }
    }
  }
}


fn count_ids_in_range(range: Range) -> Int {
  let Range(start, end) = range
  end - start + 1
}

pub fn count_all_fresh_ids(input: String) -> Int {
  let #(ranges, _) = parse_input(input)
  let merged = merge_ranges(ranges)

  list.fold(merged, 0, fn(acc, range) { acc + count_ids_in_range(range) })
}

pub fn solve_part1(input: String) -> Int {
  count_fresh(input)
}

pub fn solve_part2(input: String) -> Int {
  count_all_fresh_ids(input)
}
