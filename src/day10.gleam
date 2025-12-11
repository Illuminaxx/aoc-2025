import gleam/int
import gleam/io
import gleam/list

import gleam/string
import shellout
import simplifile

pub type Machine {
  Machine(target: List(Bool), buttons: List(List(Int)))
}

pub type MachineWithJoltage {
  MachineWithJoltage(buttons: List(List(Int)), targets: List(Int))
}

fn list_at(lst: List(a), index: Int) -> Result(a, Nil) {
  case index, lst {
    0, [first, ..] -> Ok(first)
    _, [] -> Error(Nil)
    n, [_, ..rest] if n > 0 -> list_at(rest, n - 1)
    _, _ -> Error(Nil)
  }
}

fn list_at_or(lst: List(a), index: Int, default: a) -> a {
  case list_at(lst, index) {
    Ok(val) -> val
    Error(_) -> default
  }
}

pub fn parse_machine(line: String) -> Result(Machine, Nil) {
  case string.split_once(line, "[") {
    Error(_) -> Error(Nil)
    Ok(#(_, rest)) -> {
      case string.split_once(rest, "]") {
        Error(_) -> Error(Nil)
        Ok(#(target_str, buttons_str)) -> {
          let target =
            target_str
            |> string.to_graphemes
            |> list.map(fn(c) { c == "#" })

          let buttons = parse_buttons(buttons_str)
          Ok(Machine(target, buttons))
        }
      }
    }
  }
}

pub fn parse_machine_joltage(line: String) -> Result(MachineWithJoltage, Nil) {
  case string.split_once(line, "]") {
    Error(_) -> Error(Nil)
    Ok(#(_, rest)) -> {
      let buttons = parse_buttons(rest)

      case string.split_once(rest, "{") {
        Error(_) -> Error(Nil)
        Ok(#(_, joltage_part)) -> {
          case string.split_once(joltage_part, "}") {
            Error(_) -> Error(Nil)
            Ok(#(joltage_str, _)) -> {
              let targets =
                joltage_str
                |> string.split(",")
                |> list.filter_map(fn(s) { int.parse(string.trim(s)) })

              Ok(MachineWithJoltage(buttons, targets))
            }
          }
        }
      }
    }
  }
}

fn parse_buttons(input: String) -> List(List(Int)) {
  extract_button_groups(input, [])
}

fn extract_button_groups(input: String, acc: List(List(Int))) -> List(List(Int)) {
  case string.split_once(input, "(") {
    Error(_) -> list.reverse(acc)
    Ok(#(_, rest)) -> {
      case string.split_once(rest, ")") {
        Error(_) -> list.reverse(acc)
        Ok(#(button_str, remaining)) -> {
          let indices =
            button_str
            |> string.split(",")
            |> list.filter_map(fn(s) { int.parse(string.trim(s)) })

          extract_button_groups(remaining, [indices, ..acc])
        }
      }
    }
  }
}

pub fn solve_machine_bruteforce(machine: Machine) -> Int {
  let Machine(target, buttons) = machine
  let num_buttons = list.length(buttons)
  let num_lights = list.length(target)

  find_min_presses(buttons, target, num_lights, 0, num_buttons, 999_999)
}

fn find_min_presses(
  buttons: List(List(Int)),
  target: List(Bool),
  num_lights: Int,
  current_mask: Int,
  max_buttons: Int,
  min_found: Int,
) -> Int {
  case current_mask >= int.bitwise_shift_left(1, max_buttons) {
    True -> min_found
    False -> {
      let state = apply_buttons(buttons, current_mask, num_lights)

      case state == target {
        True -> {
          let num_presses = count_bits(current_mask)
          let new_min = int.min(min_found, num_presses)
          find_min_presses(
            buttons,
            target,
            num_lights,
            current_mask + 1,
            max_buttons,
            new_min,
          )
        }
        False -> {
          find_min_presses(
            buttons,
            target,
            num_lights,
            current_mask + 1,
            max_buttons,
            min_found,
          )
        }
      }
    }
  }
}

fn apply_buttons(
  buttons: List(List(Int)),
  mask: Int,
  num_lights: Int,
) -> List(Bool) {
  let initial_state = list.repeat(False, num_lights)

  list.index_fold(buttons, initial_state, fn(state, button, idx) {
    case int.bitwise_and(mask, int.bitwise_shift_left(1, idx)) != 0 {
      True -> toggle_lights(state, button)
      False -> state
    }
  })
}

fn toggle_lights(state: List(Bool), indices: List(Int)) -> List(Bool) {
  list.index_map(state, fn(light, idx) {
    case list.contains(indices, idx) {
      True -> !light
      False -> light
    }
  })
}

fn count_bits(n: Int) -> Int {
  case n {
    0 -> 0
    _ -> {
      let bit = int.bitwise_and(n, 1)
      bit + count_bits(int.bitwise_shift_right(n, 1))
    }
  }
}

pub fn solve_machine_joltage(machine: MachineWithJoltage) -> Int {
  let MachineWithJoltage(buttons, targets) = machine

  let formula = build_z3_formula(buttons, targets)

  case execute_z3(formula) {
    Ok(result) -> result
    Error(_) -> {
      io.println_error("Z3 failed, using greedy fallback")
      solve_greedy_fallback(buttons, targets)
    }
  }
}

fn build_z3_formula(buttons: List(List(Int)), targets: List(Int)) -> String {
  let header = "(set-logic LIA)\n(set-option :produce-models true)\n"

  let vars =
    list.index_fold(buttons, "", fn(acc, _button, i) {
      let var_name = "x" <> int.to_string(i)
      acc
      <> "(declare-const "
      <> var_name
      <> " Int)\n"
      <> "(assert (>= "
      <> var_name
      <> " 0))\n"
    })

  let constraints =
    list.index_fold(targets, "", fn(acc, target_val, counter_idx) {
      let button_indices =
        list.index_fold(buttons, [], fn(indices, button, btn_idx) {
          case list.contains(button, counter_idx) {
            True -> [btn_idx, ..indices]
            False -> indices
          }
        })
        |> list.reverse

      case button_indices {
        [] -> acc
        _ -> {
          let sum_terms =
            button_indices
            |> list.map(fn(i) { "x" <> int.to_string(i) })
            |> string.join(" ")

          acc
          <> "(assert (= (+ "
          <> sum_terms
          <> ") "
          <> int.to_string(target_val)
          <> "))\n"
        }
      }
    })

  let all_vars =
    list.index_map(buttons, fn(_button, i) { "x" <> int.to_string(i) })
    |> string.join(" ")

  let objective = "(minimize (+ " <> all_vars <> "))\n"

  let footer = "(check-sat)\n(get-objectives)\n(exit)\n"

  header <> vars <> constraints <> objective <> footer
}

fn execute_z3(formula: String) -> Result(Int, Nil) {
  let temp_file = "z3_temp.smt2"

  case simplifile.write(formula, to: temp_file) {
    Ok(_) -> {
      case shellout.command("z3", with: [temp_file], in: ".", opt: []) {
        Ok(output) -> {
          let _ = simplifile.delete(temp_file)

          parse_z3_output(output)
        }
        Error(#(_code, output)) -> {
          let _ = simplifile.delete(temp_file)
          io.println_error("Z3 command failed: " <> output)
          Error(Nil)
        }
      }
    }
    Error(_) -> Error(Nil)
  }
}

fn parse_z3_output(output: String) -> Result(Int, Nil) {
  output
  |> string.split("\n")
  |> list.find_map(fn(line) {
    case string.contains(line, ")") {
      True -> {
        line
        |> string.split(" ")
        |> list.reverse
        |> list.find_map(fn(part) {
          part
          |> string.replace(")", "")
          |> string.replace("(", "")
          |> string.trim
          |> int.parse
        })
      }
      False -> Error(Nil)
    }
  })
}

fn solve_greedy_fallback(buttons: List(List(Int)), targets: List(Int)) -> Int {
  let presses = list.repeat(0, list.length(buttons))
  let final =
    greedy_backward(buttons, targets, presses, list.length(targets) - 1)
  list.fold(final, 0, int.add)
}

fn greedy_backward(
  buttons: List(List(Int)),
  targets: List(Int),
  presses: List(Int),
  counter_idx: Int,
) -> List(Int) {
  case counter_idx < 0 {
    True -> presses
    False -> {
      let state = compute_state(buttons, presses, list.length(targets))
      let deficit =
        list_at_or(targets, counter_idx, 0) - list_at_or(state, counter_idx, 0)

      case deficit <= 0 {
        True -> greedy_backward(buttons, targets, presses, counter_idx - 1)
        False -> {
          case find_button_for_counter(buttons, counter_idx) {
            Ok(btn_idx) -> {
              let new_presses =
                list.index_map(presses, fn(p, i) {
                  case i == btn_idx {
                    True -> p + deficit
                    False -> p
                  }
                })
              greedy_backward(buttons, targets, new_presses, counter_idx - 1)
            }
            Error(_) -> presses
          }
        }
      }
    }
  }
}

fn find_button_for_counter(
  buttons: List(List(Int)),
  counter_idx: Int,
) -> Result(Int, Nil) {
  list.index_fold(buttons, #(Error(Nil), 999), fn(acc, button, idx) {
    case list.contains(button, counter_idx) {
      False -> acc
      True -> {
        let score = list.length(button)
        case score < acc.1 {
          True -> #(Ok(idx), score)
          False -> acc
        }
      }
    }
  }).0
}

fn compute_state(
  buttons: List(List(Int)),
  presses: List(Int),
  num_counters: Int,
) -> List(Int) {
  let initial = list.repeat(0, num_counters)
  list.index_fold(buttons, initial, fn(state, button, button_idx) {
    let num_press = list_at_or(presses, button_idx, 0)
    list.index_map(state, fn(val, counter_idx) {
      case list.contains(button, counter_idx) {
        True -> val + num_press
        False -> val
      }
    })
  })
}

pub fn solve_part1(input: String) -> Int {
  input
  |> string.replace("\r\n", "\n")
  |> string.trim
  |> string.split("\n")
  |> list.filter_map(parse_machine)
  |> list.map(solve_machine_bruteforce)
  |> list.fold(0, int.add)
}

pub fn solve_part2(input: String) -> Int {
  input
  |> string.replace("\r\n", "\n")
  |> string.trim
  |> string.split("\n")
  |> list.filter_map(parse_machine_joltage)
  |> list.index_map(fn(machine, idx) {
    io.println("Solving machine " <> int.to_string(idx + 1) <> "/150")
    solve_machine_joltage(machine)
  })
  |> list.fold(0, int.add)
}
