import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type State {
  State(Int, Int)
}

pub fn count_hits_part1(input: String) -> Int {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  let moves =
    list.map(lines, fn(line) {
      let trimmed = string.trim(line)
      case string.starts_with(trimmed, "L") {
        True -> -result.unwrap(int.parse(string.drop_start(trimmed, 1)), 0)
        False ->
          case string.starts_with(trimmed, "R") {
            True -> result.unwrap(int.parse(string.drop_start(trimmed, 1)), 0)
            False -> 0
          }
      }
    })

  let final_state =
    list.fold(moves, State(50, 0), fn(acc, move) {
      let State(pos, hits) = acc
      let new_pos_raw = pos + move
      let new_pos = case new_pos_raw >= 0 {
        True -> new_pos_raw % 100
        False -> {
          let remainder = new_pos_raw % 100
          case remainder {
            0 -> 0
            _ -> remainder + 100
          }
        }
      }
      let new_hits = case new_pos == 0 {
        True -> hits + 1
        False -> hits
      }
      State(new_pos, new_hits)
    })

  case final_state {
    State(_, hits) -> hits
  }
}

pub fn count_hits_part2(input: String) -> Int {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  let moves =
    list.map(lines, fn(line) {
      let trimmed = string.trim(line)
      case string.starts_with(trimmed, "L") {
        True -> -result.unwrap(int.parse(string.drop_start(trimmed, 1)), 0)
        False ->
          case string.starts_with(trimmed, "R") {
            True -> result.unwrap(int.parse(string.drop_start(trimmed, 1)), 0)
            False -> 0
          }
      }
    })

  let final_state =
    list.fold(moves, State(50, 0), fn(acc, move) {
      let State(pos, hits) = acc

      case move {
        0 -> State(pos, hits)
        _ -> {
          let raw_new_pos = pos + move

          let raw_zeroes = case raw_new_pos / 100 {
            n ->
              case n >= 0 {
                True -> n
                False -> -n
              }
          }

          let extra_zero = case raw_new_pos <= 0 && pos != 0 {
            True -> 1
            False -> 0
          }

          let total_zeroes = raw_zeroes + extra_zero

          let new_pos = case int.modulo(raw_new_pos, 100) {
            Ok(n) ->
              case n < 0 {
                True -> n + 100
                False -> n
              }
            Error(_) -> 0
          }

          State(new_pos, hits + total_zeroes)
        }
      }
    })

  case final_state {
    State(_, hits) -> hits
  }
}

pub fn count_hits(input: String) -> Int {
  count_hits_part2(input)
}
