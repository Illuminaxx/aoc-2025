import gleam/int
import gleam/list
import gleam/string

// ============ PART 1 ============
// Vérifie si un nombre est invalide (formé d'une répétition exactement 2 fois)
pub fn is_invalid_id_part1(n: Int) -> Bool {
  let s = int.to_string(n)
  let len = string.length(s)

  // La longueur doit être paire
  case len % 2 {
    0 -> {
      let half = len / 2
      let first_half = string.slice(s, 0, half)
      let second_half = string.slice(s, half, half)
      first_half == second_half
    }
    _ -> False
  }
}

// ============ PART 2 ============
// Vérifie si un nombre est invalide (formé d'une répétition au moins 2 fois)
pub fn is_invalid_id_part2(n: Int) -> Bool {
  let s = int.to_string(n)
  let len = string.length(s)

  // Essayer toutes les longueurs de séquence possibles
  check_pattern_lengths(s, len, 1)
}

fn check_pattern_lengths(s: String, len: Int, pattern_len: Int) -> Bool {
  case pattern_len > len / 2 {
    True -> False
    False -> {
      case len % pattern_len == 0 {
        True -> {
          case is_repeating_pattern(s, pattern_len, len) {
            True -> True
            False -> check_pattern_lengths(s, len, pattern_len + 1)
          }
        }
        False -> check_pattern_lengths(s, len, pattern_len + 1)
      }
    }
  }
}

fn is_repeating_pattern(s: String, pattern_len: Int, total_len: Int) -> Bool {
  let pattern = string.slice(s, 0, pattern_len)
  check_all_chunks(s, pattern, pattern_len, total_len, 0)
}

fn check_all_chunks(
  s: String,
  pattern: String,
  pattern_len: Int,
  total_len: Int,
  offset: Int,
) -> Bool {
  case offset >= total_len {
    True -> True
    False -> {
      let chunk = string.slice(s, offset, pattern_len)
      case chunk == pattern {
        True ->
          check_all_chunks(
            s,
            pattern,
            pattern_len,
            total_len,
            offset + pattern_len,
          )
        False -> False
      }
    }
  }
}

// ============ COMMUN ============
// Parse une plage "11-22" et retourne (11, 22)
pub fn parse_range(range: String) -> Result(#(Int, Int), Nil) {
  case string.split(range, "-") {
    [start_str, end_str] -> {
      case int.parse(start_str), int.parse(end_str) {
        Ok(start), Ok(end) -> Ok(#(start, end))
        _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

// Trouve tous les IDs invalides dans une plage (générique)
pub fn find_invalid_in_range(
  start: Int,
  end: Int,
  is_invalid_fn: fn(Int) -> Bool,
) -> List(Int) {
  find_invalid_helper(start, end, [], is_invalid_fn)
}

fn find_invalid_helper(
  current: Int,
  end: Int,
  acc: List(Int),
  is_invalid_fn: fn(Int) -> Bool,
) -> List(Int) {
  case current > end {
    True -> list.reverse(acc)
    False -> {
      let new_acc = case is_invalid_fn(current) {
        True -> [current, ..acc]
        False -> acc
      }
      find_invalid_helper(current + 1, end, new_acc, is_invalid_fn)
    }
  }
}

// Résout la partie 1
pub fn solve_part1(input: String) -> Int {
  solve_generic(input, is_invalid_id_part1)
}

// Résout la partie 2
pub fn solve_part2(input: String) -> Int {
  solve_generic(input, is_invalid_id_part2)
}

// Fonction générique pour résoudre
fn solve_generic(input: String, is_invalid_fn: fn(Int) -> Bool) -> Int {
  let ranges_str = string.trim(input)
  let ranges = string.split(ranges_str, ",")

  list.fold(ranges, 0, fn(acc, range_str) {
    let trimmed = string.trim(range_str)
    case parse_range(trimmed) {
      Ok(#(start, end)) -> {
        let invalid_ids = find_invalid_in_range(start, end, is_invalid_fn)
        let sum = list.fold(invalid_ids, 0, fn(sum, id) { sum + id })
        acc + sum
      }
      Error(_) -> acc
    }
  })
}
