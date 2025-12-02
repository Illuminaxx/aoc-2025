import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type State {
  State(Int, Int)
  // position, zero_hits
}

pub fn count_hits(input: String) -> Int {
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

      // Position brute (peut être négative ou > 100)
      let raw_new_pos = pos + move

      // Nombre de passages par 0 via tours complets
      let raw_zeroes = case raw_new_pos / 100 {
        n ->
          case n >= 0 {
            True -> n
            False -> -n
          }
      }

      // Cas spécial : si on devient négatif et qu'on n'était pas déjà à 0
      let extra_zero = case raw_new_pos <= 0 && pos != 0 {
        True -> 1
        False -> 0
      }

      let total_zeroes = raw_zeroes + extra_zero

      // Position finale modulo 100
      let new_pos = case int.modulo(raw_new_pos, 100) {
        Ok(n) ->
          case n < 0 {
            True -> n + 100
            False -> n
          }
        Error(_) -> 0
      }

      State(new_pos, hits + total_zeroes)
    })

  case final_state {
    State(_, hits) -> hits
  }
}
