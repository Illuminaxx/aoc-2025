import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/set.{type Set}
import gleam/string

pub type Shape {
  Shape(id: Int, cells: List(#(Int, Int)))
}

pub type Region {
  Region(width: Int, height: Int, presents: List(Int))
}

pub type Grid =
  Set(#(Int, Int))

pub fn parse_input(input: String) -> #(List(Shape), List(Region)) {
  let lines =
    input
    |> string.replace("\r\n", "\n")
    |> string.trim
    |> string.split("\n")

  let #(shapes, regions) = split_sections(lines, [], [])
  #(parse_shapes(shapes), parse_regions(regions))
}

fn split_sections(
  lines: List(String),
  shape_lines: List(String),
  region_lines: List(String),
) -> #(List(String), List(String)) {
  case lines {
    [] -> #(list.reverse(shape_lines), list.reverse(region_lines))
    [line, ..rest] -> {
      case string.contains(line, "x") && string.contains(line, ":") {
        True -> split_sections(rest, shape_lines, [line, ..region_lines])
        False -> split_sections(rest, [line, ..shape_lines], region_lines)
      }
    }
  }
}

fn parse_shapes(lines: List(String)) -> List(Shape) {
  parse_shapes_helper(lines, [], None)
}

fn parse_shapes_helper(
  lines: List(String),
  acc: List(Shape),
  current: option.Option(#(Int, List(String))),
) -> List(Shape) {
  case lines {
    [] -> {
      case current {
        Some(#(id, shape_lines)) -> {
          let shape = build_shape(id, list.reverse(shape_lines))
          list.reverse([shape, ..acc])
        }
        None -> list.reverse(acc)
      }
    }
    [line, ..rest] -> {
      case string.trim(line) {
        "" -> parse_shapes_helper(rest, acc, current)
        _ -> {
          case string.ends_with(line, ":") {
            True -> {
              case current {
                Some(#(id, shape_lines)) -> {
                  let shape = build_shape(id, list.reverse(shape_lines))
                  let new_id = case int.parse(string.replace(line, ":", "")) {
                    Ok(n) -> n
                    Error(_) -> 0
                  }
                  parse_shapes_helper(rest, [shape, ..acc], Some(#(new_id, [])))
                }
                None -> {
                  let new_id = case int.parse(string.replace(line, ":", "")) {
                    Ok(n) -> n
                    Error(_) -> 0
                  }
                  parse_shapes_helper(rest, acc, Some(#(new_id, [])))
                }
              }
            }
            False -> {
              case current {
                Some(#(id, shape_lines)) ->
                  parse_shapes_helper(
                    rest,
                    acc,
                    Some(#(id, [line, ..shape_lines])),
                  )
                None -> parse_shapes_helper(rest, acc, None)
              }
            }
          }
        }
      }
    }
  }
}

fn build_shape(id: Int, lines: List(String)) -> Shape {
  let cells =
    list.index_fold(lines, [], fn(acc, line, y) {
      let row_cells =
        line
        |> string.to_graphemes
        |> list.index_fold([], fn(row_acc, char, x) {
          case char {
            "#" -> [#(x, y), ..row_acc]
            _ -> row_acc
          }
        })
      list.append(acc, row_cells)
    })

  Shape(id, cells)
}

fn parse_regions(lines: List(String)) -> List(Region) {
  list.filter_map(lines, parse_region)
}

fn parse_region(line: String) -> Result(Region, Nil) {
  case string.split(line, ":") {
    [size_str, presents_str] -> {
      case string.split(size_str, "x") {
        [w_str, h_str] -> {
          case int.parse(w_str), int.parse(h_str) {
            Ok(width), Ok(height) -> {
              let presents =
                presents_str
                |> string.trim
                |> string.split(" ")
                |> list.filter_map(int.parse)

              Ok(Region(width, height, presents))
            }
            _, _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn normalize_cells(cells: List(#(Int, Int))) -> List(#(Int, Int)) {
  case cells {
    [] -> []
    _ -> {
      let min_x =
        list.fold(cells, 999_999, fn(acc, cell) {
          let #(x, _) = cell
          int.min(acc, x)
        })
      let min_y =
        list.fold(cells, 999_999, fn(acc, cell) {
          let #(_, y) = cell
          int.min(acc, y)
        })

      cells
      |> list.map(fn(cell) {
        let #(x, y) = cell
        #(x - min_x, y - min_y)
      })
      |> list.sort(fn(a, b) {
        let #(x1, y1) = a
        let #(x2, y2) = b
        case int.compare(y1, y2) {
          order.Eq -> int.compare(x1, x2)
          other -> other
        }
      })
    }
  }
}

fn rotate_90(cells: List(#(Int, Int))) -> List(#(Int, Int)) {
  cells
  |> list.map(fn(cell) {
    let #(x, y) = cell
    #(-y, x)
  })
  |> normalize_cells
}

fn flip_horizontal(cells: List(#(Int, Int))) -> List(#(Int, Int)) {
  cells
  |> list.map(fn(cell) {
    let #(x, y) = cell
    #(-x, y)
  })
  |> normalize_cells
}

fn get_all_orientations(shape: Shape) -> List(List(#(Int, Int))) {
  let Shape(_, cells) = shape

  let r0 = normalize_cells(cells)
  let r90 = rotate_90(r0)
  let r180 = rotate_90(r90)
  let r270 = rotate_90(r180)

  let f0 = flip_horizontal(r0)
  let f90 = rotate_90(f0)
  let f180 = rotate_90(f90)
  let f270 = rotate_90(f180)

  [r0, r90, r180, r270, f0, f90, f180, f270]
  |> list.unique
}

fn quick_feasibility_check(region: Region, shapes: List(Shape)) -> Bool {
  let Region(width, height, presents) = region
  let area = width * height

  let total_cells =
    list.index_fold(presents, 0, fn(acc, count, shape_id) {
      case list.find(shapes, fn(s) { s.id == shape_id }) {
        Ok(shape) -> {
          let shape_size = list.length(shape.cells)
          acc + count * shape_size
        }
        Error(_) -> acc
      }
    })

  total_cells <= area
}

fn solve_region_with_limit(
  region: Region,
  shapes: List(Shape),
  max_attempts: Int,
) -> Bool {
  let Region(width, height, presents) = region

  case quick_feasibility_check(region, shapes) {
    False -> False
    True -> {
      let total_shapes = list.fold(presents, 0, int.add)

      case total_shapes > 100 {
        True -> {
          greedy_fill(region, shapes)
        }
        False -> {
          let shapes_to_place = build_shapes_to_place(presents, shapes)
          let sorted_shapes = sort_shapes_by_size(shapes_to_place)
          backtrack_limited(
            sorted_shapes,
            width,
            height,
            set.new(),
            0,
            max_attempts,
          )
        }
      }
    }
  }
}

fn greedy_fill(region: Region, shapes: List(Shape)) -> Bool {
  let Region(width, height, presents) = region

  let shapes_to_place = build_shapes_list(presents, shapes)

  greedy_backtrack(shapes_to_place, width, height, set.new())
}

fn build_shapes_list(
  presents: List(Int),
  shapes: List(Shape),
) -> List(#(Int, Shape)) {
  list.index_fold(presents, [], fn(acc, count, shape_id) {
    case count {
      0 -> acc
      _ -> {
        case list.find(shapes, fn(s) { s.id == shape_id }) {
          Ok(shape) -> {
            let instances =
              list.range(0, count - 1) |> list.map(fn(i) { #(i, shape) })
            list.append(acc, instances)
          }
          Error(_) -> acc
        }
      }
    }
  })
}

fn greedy_backtrack(
  remaining: List(#(Int, Shape)),
  width: Int,
  height: Int,
  grid: Grid,
) -> Bool {
  case remaining {
    [] -> True
    [#(_idx, shape), ..rest] -> {
      let orientations = get_all_orientations(shape)
      try_place_greedy(orientations, rest, width, height, grid)
    }
  }
}

fn try_place_greedy(
  orientations: List(List(#(Int, Int))),
  remaining: List(#(Int, Shape)),
  width: Int,
  height: Int,
  grid: Grid,
) -> Bool {
  case orientations {
    [] -> False
    [cells, ..other_orientations] -> {
      case find_first_valid_position(cells, width, height, grid, 0, 0) {
        Some(#(x, y)) -> {
          let new_grid = place_shape(cells, x, y, grid)
          case greedy_backtrack(remaining, width, height, new_grid) {
            True -> True
            False ->
              try_place_greedy(
                other_orientations,
                remaining,
                width,
                height,
                grid,
              )
          }
        }
        None ->
          try_place_greedy(other_orientations, remaining, width, height, grid)
      }
    }
  }
}

fn find_first_valid_position(
  cells: List(#(Int, Int)),
  width: Int,
  height: Int,
  grid: Grid,
  x: Int,
  y: Int,
) -> option.Option(#(Int, Int)) {
  case y >= height {
    True -> None
    False -> {
      case x >= width {
        True -> find_first_valid_position(cells, width, height, grid, 0, y + 1)
        False -> {
          case can_place(cells, x, y, width, height, grid) {
            True -> Some(#(x, y))
            False ->
              find_first_valid_position(cells, width, height, grid, x + 1, y)
          }
        }
      }
    }
  }
}

fn build_shapes_to_place(
  presents: List(Int),
  shapes: List(Shape),
) -> List(#(Int, List(List(#(Int, Int))))) {
  list.index_fold(presents, [], fn(acc, count, shape_id) {
    case count {
      0 -> acc
      _ -> {
        case list.find(shapes, fn(s) { s.id == shape_id }) {
          Ok(shape) -> {
            let orientations = get_all_orientations(shape)
            let shapes_list =
              list.range(0, count - 1)
              |> list.map(fn(_) { #(shape_id, orientations) })
            list.append(acc, shapes_list)
          }
          Error(_) -> acc
        }
      }
    }
  })
}

fn sort_shapes_by_size(
  shapes: List(#(Int, List(List(#(Int, Int))))),
) -> List(#(Int, List(List(#(Int, Int))))) {
  list.sort(shapes, fn(a, b) {
    let #(_, orientations_a) = a
    let #(_, orientations_b) = b
    case orientations_a, orientations_b {
      [first_a, ..], [first_b, ..] -> {
        let size_a = list.length(first_a)
        let size_b = list.length(first_b)
        int.compare(size_b, size_a)
      }
      _, _ -> order.Eq
    }
  })
}

fn backtrack_limited(
  remaining_shapes: List(#(Int, List(List(#(Int, Int))))),
  width: Int,
  height: Int,
  grid: Grid,
  attempts: Int,
  max_attempts: Int,
) -> Bool {
  case attempts >= max_attempts {
    True -> False
    False -> {
      case remaining_shapes {
        [] -> True
        [#(_shape_id, orientations), ..rest] -> {
          try_orientations_limited(
            orientations,
            rest,
            width,
            height,
            grid,
            attempts,
            max_attempts,
          )
        }
      }
    }
  }
}

fn try_orientations_limited(
  orientations: List(List(#(Int, Int))),
  remaining: List(#(Int, List(List(#(Int, Int))))),
  width: Int,
  height: Int,
  grid: Grid,
  attempts: Int,
  max_attempts: Int,
) -> Bool {
  case orientations {
    [] -> False
    [cells, ..other_orientations] -> {
      case
        try_all_positions_limited(
          cells,
          remaining,
          width,
          height,
          grid,
          0,
          0,
          attempts,
          max_attempts,
        )
      {
        True -> True
        False ->
          try_orientations_limited(
            other_orientations,
            remaining,
            width,
            height,
            grid,
            attempts + 1,
            max_attempts,
          )
      }
    }
  }
}

fn try_all_positions_limited(
  cells: List(#(Int, Int)),
  remaining: List(#(Int, List(List(#(Int, Int))))),
  width: Int,
  height: Int,
  grid: Grid,
  x: Int,
  y: Int,
  attempts: Int,
  max_attempts: Int,
) -> Bool {
  case y >= height {
    True -> False
    False -> {
      case x >= width {
        True ->
          try_all_positions_limited(
            cells,
            remaining,
            width,
            height,
            grid,
            0,
            y + 1,
            attempts,
            max_attempts,
          )
        False -> {
          case can_place(cells, x, y, width, height, grid) {
            True -> {
              let new_grid = place_shape(cells, x, y, grid)
              case
                backtrack_limited(
                  remaining,
                  width,
                  height,
                  new_grid,
                  attempts + 1,
                  max_attempts,
                )
              {
                True -> True
                False ->
                  try_all_positions_limited(
                    cells,
                    remaining,
                    width,
                    height,
                    grid,
                    x + 1,
                    y,
                    attempts,
                    max_attempts,
                  )
              }
            }
            False ->
              try_all_positions_limited(
                cells,
                remaining,
                width,
                height,
                grid,
                x + 1,
                y,
                attempts,
                max_attempts,
              )
          }
        }
      }
    }
  }
}

fn can_place(
  cells: List(#(Int, Int)),
  x: Int,
  y: Int,
  width: Int,
  height: Int,
  grid: Grid,
) -> Bool {
  list.all(cells, fn(cell) {
    let #(dx, dy) = cell
    let nx = x + dx
    let ny = y + dy

    nx >= 0
    && nx < width
    && ny >= 0
    && ny < height
    && !set.contains(grid, #(nx, ny))
  })
}

fn place_shape(cells: List(#(Int, Int)), x: Int, y: Int, grid: Grid) -> Grid {
  list.fold(cells, grid, fn(g, cell) {
    let #(dx, dy) = cell
    set.insert(g, #(x + dx, y + dy))
  })
}

pub fn solve_part1(input: String) -> Int {
  let #(shapes, regions) = parse_input(input)

  regions
  |> list.filter(fn(region) { solve_region_with_limit(region, shapes, 100_000) })
  |> list.length
}
