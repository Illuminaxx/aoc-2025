import gleam/int
import gleam/list
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub fn parse_points(input: String) -> List(Point) {
  input
  |> string.replace("\r\n", "\n")
  |> string.trim
  |> string.split("\n")
  |> list.filter_map(parse_point)
}

fn parse_point(line: String) -> Result(Point, Nil) {
  case string.split(line, ",") {
    [x_str, y_str] -> {
      case int.parse(x_str), int.parse(y_str) {
        Ok(x), Ok(y) -> Ok(Point(x, y))
        _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn rectangle_area(p1: Point, p2: Point) -> Int {
  let Point(x1, y1) = p1
  let Point(x2, y2) = p2

  let width = int.absolute_value(x2 - x1) + 1
  let height = int.absolute_value(y2 - y1) + 1

  width * height
}

pub fn find_largest_rectangle(points: List(Point)) -> Int {
  find_largest_helper(points, 0)
}

fn find_largest_helper(points: List(Point), max_area: Int) -> Int {
  case points {
    [] -> max_area
    [p1, ..rest] -> {
      let areas = list.map(rest, fn(p2) { rectangle_area(p1, p2) })
      let local_max = list.fold(areas, max_area, int.max)

      find_largest_helper(rest, local_max)
    }
  }
}

fn point_in_polygon(point: Point, polygon: List(Point)) -> Bool {
  let Point(x, y) = point
  let intersections = count_ray_intersections(x, y, polygon)
  intersections % 2 == 1
}

fn count_ray_intersections(x: Int, y: Int, polygon: List(Point)) -> Int {
  let pairs = make_edge_pairs(polygon)
  list.fold(pairs, 0, fn(acc, pair) {
    let #(p1, p2) = pair
    case intersects_ray(x, y, p1, p2) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn make_edge_pairs(polygon: List(Point)) -> List(#(Point, Point)) {
  case polygon {
    [] | [_] -> []
    [first, ..] -> {
      let edges = make_consecutive_pairs(polygon, [])

      case list.last(polygon) {
        Ok(last) -> list.append(edges, [#(last, first)])
        Error(_) -> edges
      }
    }
  }
}

fn make_consecutive_pairs(
  points: List(Point),
  acc: List(#(Point, Point)),
) -> List(#(Point, Point)) {
  case points {
    [] | [_] -> list.reverse(acc)
    [p1, p2, ..rest] -> {
      make_consecutive_pairs([p2, ..rest], [#(p1, p2), ..acc])
    }
  }
}

fn intersects_ray(x: Int, y: Int, p1: Point, p2: Point) -> Bool {
  let Point(x1, y1) = p1
  let Point(x2, y2) = p2

  case y1 == y2 {
    True -> False

    False -> {
      let y_min = int.min(y1, y2)
      let y_max = int.max(y1, y2)

      case y >= y_min && y < y_max {
        False -> False
        True -> {
          let x_intersect = x1 + { y - y1 } * { x2 - x1 } / { y2 - y1 }
          x_intersect > x
        }
      }
    }
  }
}

fn point_on_segment(point: Point, p1: Point, p2: Point) -> Bool {
  let Point(x, y) = point
  let Point(x1, y1) = p1
  let Point(x2, y2) = p2

  case x1 == x2 {
    True -> {
      x == x1 && y >= int.min(y1, y2) && y <= int.max(y1, y2)
    }
    False -> {
      case y1 == y2 {
        True -> {
          y == y1 && x >= int.min(x1, x2) && x <= int.max(x1, x2)
        }
        False -> {
          False
        }
      }
    }
  }
}

fn point_on_edge(point: Point, polygon: List(Point)) -> Bool {
  let edges = make_edge_pairs(polygon)
  list.any(edges, fn(edge) {
    let #(p1, p2) = edge
    point_on_segment(point, p1, p2)
  })
}

fn is_valid_point(point: Point, polygon: List(Point)) -> Bool {
  point_in_polygon(point, polygon)
  || list.contains(polygon, point)
  || point_on_edge(point, polygon)
}

fn rectangle_in_polygon(p1: Point, p2: Point, polygon: List(Point)) -> Bool {
  let Point(x1, y1) = p1
  let Point(x2, y2) = p2

  let min_x = int.min(x1, x2)
  let max_x = int.max(x1, x2)
  let min_y = int.min(y1, y2)
  let max_y = int.max(y1, y2)

  let corners = [
    Point(min_x, min_y),
    Point(min_x, max_y),
    Point(max_x, min_y),
    Point(max_x, max_y),
  ]

  let corners_ok =
    list.all(corners, fn(corner) { is_valid_point(corner, polygon) })

  case corners_ok {
    False -> False
    True -> {
      let width = max_x - min_x
      let height = max_y - min_y

      case width <= 2 && height <= 2 {
        True -> True
        False -> {
          let num_samples = int.min(100, int.max(20, { width + height } / 1000))

          let step_x = int.max(1, width / num_samples)
          let step_y = int.max(1, height / num_samples)

          check_rectangle_grid(
            min_x,
            max_x,
            min_y,
            max_y,
            step_x,
            step_y,
            polygon,
          )
        }
      }
    }
  }
}

fn check_rectangle_grid(
  min_x: Int,
  max_x: Int,
  min_y: Int,
  max_y: Int,
  step_x: Int,
  step_y: Int,
  polygon: List(Point),
) -> Bool {
  check_x_range(max_x, min_y, max_y, min_x, step_x, step_y, polygon)
}

fn check_x_range(
  max_x: Int,
  min_y: Int,
  max_y: Int,
  current_x: Int,
  step_x: Int,
  step_y: Int,
  polygon: List(Point),
) -> Bool {
  case current_x > max_x {
    True -> True
    False -> {
      let valid = check_y_range(max_y, current_x, min_y, step_y, polygon)
      case valid {
        False -> False
        True ->
          check_x_range(
            max_x,
            min_y,
            max_y,
            current_x + step_x,
            step_x,
            step_y,
            polygon,
          )
      }
    }
  }
}

fn check_y_range(
  max_y: Int,
  x: Int,
  current_y: Int,
  step_y: Int,
  polygon: List(Point),
) -> Bool {
  case current_y > max_y {
    True -> True
    False -> {
      let point = Point(x, current_y)
      let valid = is_valid_point(point, polygon)
      case valid {
        False -> False
        True -> check_y_range(max_y, x, current_y + step_y, step_y, polygon)
      }
    }
  }
}

pub fn find_largest_rectangle_in_polygon(points: List(Point)) -> Int {
  find_largest_in_polygon_helper(points, points, 0)
}

fn find_largest_in_polygon_helper(
  all_points: List(Point),
  remaining: List(Point),
  max_area: Int,
) -> Int {
  case remaining {
    [] -> max_area
    [p1, ..rest] -> {
      let areas =
        list.filter_map(all_points, fn(p2) {
          case p1 == p2 {
            True -> Error(Nil)
            False -> {
              case rectangle_in_polygon(p1, p2, all_points) {
                True -> Ok(rectangle_area(p1, p2))
                False -> Error(Nil)
              }
            }
          }
        })

      let local_max = list.fold(areas, max_area, int.max)

      find_largest_in_polygon_helper(all_points, rest, local_max)
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  let points = parse_points(input)

  find_largest_rectangle(points)
}

pub fn solve_part2(input: String) -> Int {
  let points = parse_points(input)

  find_largest_rectangle_in_polygon(points)
}
