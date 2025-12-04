import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Position =
  #(Int, Int)

pub type Grid =
  Dict(Position, String)

pub fn parse_grid(input: String) -> Grid {
  let lines = input |> string.trim |> string.split("\n")

  parse_lines(lines, 0, dict.new())
}

fn parse_lines(lines: List(String), row: Int, grid: Grid) -> Grid {
  case lines {
    [] -> grid
    [line, ..rest] -> {
      let new_grid = parse_line(line, row, 0, grid)
      parse_lines(rest, row + 1, new_grid)
    }
  }
}

fn parse_line(line: String, row: Int, col: Int, grid: Grid) -> Grid {
  let chars = string.to_graphemes(line)
  parse_chars(chars, row, col, grid)
}

fn parse_chars(chars: List(String), row: Int, col: Int, grid: Grid) -> Grid {
  case chars {
    [] -> grid
    [char, ..rest] -> {
      let new_grid = dict.insert(grid, #(row, col), char)
      parse_chars(rest, row, col + 1, new_grid)
    }
  }
}

fn get_neighbors(pos: Position) -> List(Position) {
  let #(row, col) = pos
  [
    #(row - 1, col - 1),
    #(row - 1, col),
    #(row - 1, col + 1),
    #(row, col - 1),
    #(row, col + 1),
    #(row + 1, col - 1),
    #(row + 1, col),
    #(row + 1, col + 1),
  ]
}

fn count_roll_neighbors(grid: Grid, pos: Position) -> Int {
  let neighbors = get_neighbors(pos)

  list.fold(neighbors, 0, fn(count, neighbor_pos) {
    case dict.get(grid, neighbor_pos) {
      Ok("@") -> count + 1
      _ -> count
    }
  })
}

pub fn is_accessible(grid: Grid, pos: Position) -> Bool {
  case dict.get(grid, pos) {
    Ok("@") -> {
      let neighbor_count = count_roll_neighbors(grid, pos)
      neighbor_count < 4
    }
    _ -> False
  }
}

pub fn count_accessible_rolls(input: String) -> Int {
  let grid = parse_grid(input)
  let positions = dict.keys(grid)

  list.fold(positions, 0, fn(count, pos) {
    case is_accessible(grid, pos) {
      True -> count + 1
      False -> count
    }
  })
}

fn find_accessible_rolls(grid: Grid) -> Set(Position) {
  let positions = dict.keys(grid)

  list.fold(positions, set.new(), fn(acc, pos) {
    case is_accessible(grid, pos) {
      True -> set.insert(acc, pos)
      False -> acc
    }
  })
}

fn remove_rolls(grid: Grid, to_remove: Set(Position)) -> Grid {
  set.fold(to_remove, grid, fn(g, pos) { dict.insert(g, pos, ".") })
}

pub fn simulate_removal(input: String) -> Int {
  let grid = parse_grid(input)
  remove_cascade(grid, 0)
}

fn remove_cascade(grid: Grid, total_removed: Int) -> Int {
  let accessible = find_accessible_rolls(grid)
  let count = set.size(accessible)

  case count {
    0 -> total_removed
    _ -> {
      let new_grid = remove_rolls(grid, accessible)
      remove_cascade(new_grid, total_removed + count)
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  count_accessible_rolls(input)
}

pub fn solve_part2(input: String) -> Int {
  simulate_removal(input)
}
