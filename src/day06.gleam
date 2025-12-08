import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Operation {
  Add
  Multiply
}

pub type Problem {
  Problem(numbers: List(Int), operation: Operation)
}

pub fn solve_problem(problem: Problem) -> Int {
  let Problem(numbers, operation) = problem

  case operation {
    Add -> list.fold(numbers, 0, fn(acc, n) { acc + n })
    Multiply -> list.fold(numbers, 1, fn(acc, n) { acc * n })
  }
}

fn tokenize(line: String) -> List(String) {
  line
  |> string.split(" ")
  |> list.filter(fn(token) { string.trim(token) != "" })
}

fn pad_right(s: String, width: Int, pad: String) -> String {
  let current_len = string.length(s)
  case current_len >= width {
    True -> s
    False -> {
      let padding_needed = width - current_len
      let padding = string.repeat(pad, padding_needed)
      s <> padding
    }
  }
}

fn list_at(lst: List(a), index: Int) -> Result(a, Nil) {
  case index, lst {
    0, [first, ..] -> Ok(first)
    _, [] -> Error(Nil)
    n, [_, ..rest] -> list_at(rest, n - 1)
  }
}

pub fn parse_worksheet(input: String) -> List(Problem) {
  let lines =
    input
    |> string.replace("\r\n", "\n")
    |> string.trim
    |> string.split("\n")
    |> list.filter(fn(line) { string.trim(line) != "" })

  case list.reverse(lines) {
    [] -> []
    [operators_line, ..number_lines_reversed] -> {
      let number_lines = list.reverse(number_lines_reversed)

      let number_token_rows = list.map(number_lines, tokenize)
      let operator_tokens = tokenize(operators_line)

      transpose_by_index(number_token_rows, operator_tokens, 0, [])
    }
  }
}

fn transpose_by_index(
  number_rows: List(List(String)),
  operators: List(String),
  col_index: Int,
  acc: List(Problem),
) -> List(Problem) {
  case list_at(operators, col_index) {
    Error(_) -> list.reverse(acc)
    Ok(op_str) -> {
      let operation = case string.trim(op_str) {
        "+" -> Ok(Add)
        "*" -> Ok(Multiply)
        _ -> Error(Nil)
      }

      case operation {
        Ok(op) -> {
          let numbers =
            list.filter_map(number_rows, fn(row) {
              case list_at(row, col_index) {
                Ok(num_str) -> int.parse(num_str)
                Error(_) -> Error(Nil)
              }
            })

          case list.is_empty(numbers) {
            True ->
              transpose_by_index(number_rows, operators, col_index + 1, acc)
            False -> {
              let problem = Problem(numbers, op)
              transpose_by_index(number_rows, operators, col_index + 1, [
                problem,
                ..acc
              ])
            }
          }
        }
        Error(_) ->
          transpose_by_index(number_rows, operators, col_index + 1, acc)
      }
    }
  }
}

pub fn parse_worksheet_rtl(input: String) -> List(Problem) {
  let lines =
    input
    |> string.replace("\r\n", "\n")
    |> string.split("\n")
    |> list.filter(fn(line) { string.trim(line) != "" })

  case list.reverse(lines) {
    [] -> []
    [operators_line, ..number_lines_reversed] -> {
      let number_lines = list.reverse(number_lines_reversed)
      let operator_chars = string.to_graphemes(operators_line)

      let max_width =
        list.fold(number_lines, 0, fn(max, line) {
          int.max(max, string.length(line))
        })

      let padded =
        list.map(number_lines, fn(line) { pad_right(line, max_width, " ") })

      let columns =
        list.map(list.range(0, max_width - 1), fn(i) {
          let digits = list.map(padded, fn(l) { string.slice(l, i, 1) })

          let op = case list_at(operator_chars, i) {
            Ok(c) -> c
            Error(_) -> " "
          }

          #(digits, op)
        })

      let problems = split_blocks(columns, [])
      list.map(problems, make_problem)
    }
  }
}

fn split_blocks(
  cols: List(#(List(String), String)),
  acc: List(List(#(List(String), String))),
) -> List(List(#(List(String), String))) {
  case cols {
    [] -> list.reverse(acc)
    [c, ..rest] -> {
      let #(digits, _op) = c

      case list.all(digits, fn(d) { d == " " }) {
        True -> split_blocks(rest, acc)
        False -> {
          let block = take_block(cols)
          split_blocks(drop_block(cols), [block, ..acc])
        }
      }
    }
  }
}

fn take_block(
  cols: List(#(List(String), String)),
) -> List(#(List(String), String)) {
  case cols {
    [] -> []
    [c, ..rest] -> {
      let #(digits, _) = c
      case list.all(digits, fn(d) { d == " " }) {
        True -> []
        False -> [c, ..take_block(rest)]
      }
    }
  }
}

fn drop_block(
  cols: List(#(List(String), String)),
) -> List(#(List(String), String)) {
  case cols {
    [] -> []
    [c, ..rest] -> {
      let #(digits, _) = c
      case list.all(digits, fn(d) { d == " " }) {
        True -> rest
        False -> drop_block(rest)
      }
    }
  }
}

fn first_operator(cols: List(#(List(String), String))) -> Operation {
  cols
  |> list.filter_map(fn(pair) {
    let #(_, op) = pair
    case op {
      "*" -> Ok(Multiply)
      "+" -> Ok(Add)
      _ -> Error(Nil)
    }
  })
  |> list.first
  |> result.unwrap(Add)
}

fn make_problem(cols: List(#(List(String), String))) -> Problem {
  let op = first_operator(cols)

  let nums =
    cols
    |> list.map(fn(pair) {
      let #(digits, _) = pair
      digits
      |> list.filter(fn(c) { c != " " })
      |> string.join("")
      |> int.parse
      |> result.unwrap(0)
    })

  Problem(nums, op)
}

pub fn solve_worksheet(input: String) -> Int {
  let problems = parse_worksheet(input)
  list.fold(problems, 0, fn(acc, problem) { acc + solve_problem(problem) })
}

pub fn solve_worksheet_rtl(input: String) -> Int {
  let problems = parse_worksheet_rtl(input)
  list.fold(problems, 0, fn(acc, problem) { acc + solve_problem(problem) })
}

pub fn solve_part1(input: String) -> Int {
  solve_worksheet(input)
}

pub fn solve_part2(input: String) -> Int {
  solve_worksheet_rtl(input)
}
