import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Position {
  Position(row: Int, col: Int)
}

pub type Grid {
  Grid(cells: Dict(Position, String), rows: Int, cols: Int, start: Position)
}

pub fn parse_grid(input: String) -> Grid {
  let lines =
    input
    |> string.replace("\r\n", "\n")
    |> string.trim
    |> string.split("\n")

  let rows = list.length(lines)
  let cols = case list.first(lines) {
    Ok(line) -> string.length(line)
    Error(_) -> 0
  }

  let cells_and_start =
    list.index_fold(lines, #(dict.new(), Position(0, 0)), fn(acc, line, row) {
      let #(cells, start) = acc
      let chars = string.to_graphemes(line)

      list.index_fold(chars, #(cells, start), fn(acc2, char, col) {
        let #(cells2, start2) = acc2
        let pos = Position(row, col)
        let new_cells = dict.insert(cells2, pos, char)

        case char {
          "S" -> #(new_cells, pos)
          _ -> #(new_cells, start2)
        }
      })
    })

  let #(final_cells, start_pos) = cells_and_start

  Grid(final_cells, rows, cols, start_pos)
}

pub fn simulate(grid: Grid) -> Int {
  let Grid(cells, rows, cols, start) = grid

  let initial_beams = [start]

  simulate_step(cells, rows, cols, initial_beams, set.new(), 0)
}

fn simulate_step(
  cells: Dict(Position, String),
  rows: Int,
  cols: Int,
  beams: List(Position),
  visited_splitters: Set(Position),
  split_count: Int,
) -> Int {
  case beams {
    [] -> split_count
    _ -> {
      let result =
        propagate_beams(
          cells,
          rows,
          cols,
          beams,
          visited_splitters,
          split_count,
        )
      let #(new_beams, new_visited, new_count) = result

      simulate_step(cells, rows, cols, new_beams, new_visited, new_count)
    }
  }
}

fn propagate_beams(
  cells: Dict(Position, String),
  rows: Int,
  cols: Int,
  beams: List(Position),
  visited_splitters: Set(Position),
  split_count: Int,
) -> #(List(Position), Set(Position), Int) {
  list.fold(beams, #([], visited_splitters, split_count), fn(acc, beam) {
    let #(new_beams_acc, visited_acc, count_acc) = acc
    let Position(row, col) = beam

    let next_pos = Position(row + 1, col)

    case row + 1 >= rows {
      True -> #(new_beams_acc, visited_acc, count_acc)
      False -> {
        case dict.get(cells, next_pos) {
          Error(_) -> #(new_beams_acc, visited_acc, count_acc)
          Ok(cell) -> {
            case cell {
              "^" -> {
                case set.contains(visited_acc, next_pos) {
                  True -> #(new_beams_acc, visited_acc, count_acc)
                  False -> {
                    let new_visited = set.insert(visited_acc, next_pos)
                    let new_count = count_acc + 1

                    let left = Position(row + 1, col - 1)
                    let right = Position(row + 1, col + 1)

                    let beams_to_add =
                      [left, right]
                      |> list.filter(fn(pos) {
                        let Position(_, c) = pos
                        c >= 0 && c < cols
                      })

                    #(
                      list.append(new_beams_acc, beams_to_add),
                      new_visited,
                      new_count,
                    )
                  }
                }
              }
              _ -> {
                #([next_pos, ..new_beams_acc], visited_acc, count_acc)
              }
            }
          }
        }
      }
    }
  })
}

pub fn count_timelines(grid: Grid) -> Int {
  let Grid(cells, rows, cols, start) = grid

  let initial_beams = dict.from_list([#(start, 1)])

  simulate_timelines(cells, rows, cols, initial_beams)
}

fn simulate_timelines(
  cells: Dict(Position, String),
  rows: Int,
  cols: Int,
  beams: Dict(Position, Int),
) -> Int {
  case dict.is_empty(beams) {
    True -> 0
    False -> {
      let #(next_beams, exited_count) =
        propagate_timeline_beams(cells, rows, cols, beams)

      exited_count + simulate_timelines(cells, rows, cols, next_beams)
    }
  }
}

fn propagate_timeline_beams(
  cells: Dict(Position, String),
  rows: Int,
  cols: Int,
  beams: Dict(Position, Int),
) -> #(Dict(Position, Int), Int) {
  dict.fold(beams, #(dict.new(), 0), fn(acc, beam_pos, timeline_count) {
    let #(new_beams_acc, exited_acc) = acc
    let Position(row, col) = beam_pos

    let next_row = row + 1

    case next_row >= rows {
      True -> #(new_beams_acc, exited_acc + timeline_count)
      False -> {
        let next_pos = Position(next_row, col)

        case dict.get(cells, next_pos) {
          Error(_) -> #(new_beams_acc, exited_acc)
          Ok(cell) -> {
            case cell {
              "^" -> {
                let left = Position(next_row, col - 1)
                let right = Position(next_row, col + 1)

                let acc2 = case col - 1 >= 0 {
                  True -> add_timelines(new_beams_acc, left, timeline_count)
                  False -> new_beams_acc
                }

                let acc3 = case col + 1 < cols {
                  True -> add_timelines(acc2, right, timeline_count)
                  False -> acc2
                }

                #(acc3, exited_acc)
              }
              _ -> {
                #(
                  add_timelines(new_beams_acc, next_pos, timeline_count),
                  exited_acc,
                )
              }
            }
          }
        }
      }
    }
  })
}

fn add_timelines(
  positions: Dict(Position, Int),
  pos: Position,
  count: Int,
) -> Dict(Position, Int) {
  case dict.get(positions, pos) {
    Ok(existing) -> dict.insert(positions, pos, existing + count)
    Error(_) -> dict.insert(positions, pos, count)
  }
}

pub fn solve_part1(input: String) -> Int {
  let grid = parse_grid(input)
  simulate(grid)
}

pub fn solve_part2(input: String) -> Int {
  let grid = parse_grid(input)
  count_timelines(grid)
}
