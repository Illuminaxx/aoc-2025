import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Point {
  Point(x: Int, y: Int)
}

pub type PolygonCache {
  PolygonCache(
    points: List(Point),
    points_set: Set(Point),
    edges: List(#(Point, Point)),
    min_x: Int,
    max_x: Int,
    min_y: Int,
    max_y: Int,
  )
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

// Calculer les bornes du polygone
fn compute_bounds(points: List(Point)) -> #(Int, Int, Int, Int) {
  case points {
    [] -> #(0, 0, 0, 0)
    [Point(x, y), ..rest] -> {
      list.fold(rest, #(x, x, y, y), fn(acc, point) {
        let #(min_x, max_x, min_y, max_y) = acc
        let Point(px, py) = point
        #(
          int.min(min_x, px),
          int.max(max_x, px),
          int.min(min_y, py),
          int.max(max_y, py),
        )
      })
    }
  }
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

fn point_on_edge_cached(point: Point, cache: PolygonCache) -> Bool {
  list.any(cache.edges, fn(edge) {
    let #(p1, p2) = edge
    point_on_segment(point, p1, p2)
  })
}

fn is_valid_point_cached(point: Point, cache: PolygonCache) -> Bool {
  set.contains(cache.points_set, point)
  || point_on_edge_cached(point, cache)
  || point_in_polygon(point, cache.points)
}

// Vérification rapide des bounds avant le test complet
fn quick_bounds_check(
  min_x: Int,
  max_x: Int,
  min_y: Int,
  max_y: Int,
  cache: PolygonCache,
) -> Bool {
  // Le rectangle doit être dans les bounds du polygone
  min_x >= cache.min_x
  && max_x <= cache.max_x
  && min_y >= cache.min_y
  && max_y <= cache.max_y
}

fn rectangle_in_polygon_cached(
  p1: Point,
  p2: Point,
  cache: PolygonCache,
) -> Bool {
  let Point(x1, y1) = p1
  let Point(x2, y2) = p2

  let min_x = int.min(x1, x2)
  let max_x = int.max(x1, x2)
  let min_y = int.min(y1, y2)
  let max_y = int.max(y1, y2)

  // Quick check: si le rectangle est complètement hors des bounds
  case quick_bounds_check(min_x, max_x, min_y, max_y, cache) {
    False -> False
    True -> {
      let corners = [
        Point(min_x, min_y),
        Point(min_x, max_y),
        Point(max_x, min_y),
        Point(max_x, max_y),
      ]

      let corners_ok =
        list.all(corners, fn(corner) { is_valid_point_cached(corner, cache) })

      case corners_ok {
        False -> False
        True -> {
          let width = max_x - min_x
          let height = max_y - min_y

          case width <= 2 && height <= 2 {
            True -> True
            False -> {
              let num_samples =
                int.min(100, int.max(20, { width + height } / 1000))

              let step_x = int.max(1, width / num_samples)
              let step_y = int.max(1, height / num_samples)

              check_rectangle_grid_cached(
                min_x,
                max_x,
                min_y,
                max_y,
                step_x,
                step_y,
                cache,
              )
            }
          }
        }
      }
    }
  }
}

fn check_rectangle_grid_cached(
  min_x: Int,
  max_x: Int,
  min_y: Int,
  max_y: Int,
  step_x: Int,
  step_y: Int,
  cache: PolygonCache,
) -> Bool {
  check_x_range_cached(max_x, min_y, max_y, min_x, step_x, step_y, cache)
}

fn check_x_range_cached(
  max_x: Int,
  min_y: Int,
  max_y: Int,
  current_x: Int,
  step_x: Int,
  step_y: Int,
  cache: PolygonCache,
) -> Bool {
  case current_x > max_x {
    True -> True
    False -> {
      let valid = check_y_range_cached(max_y, current_x, min_y, step_y, cache)
      case valid {
        False -> False
        True ->
          check_x_range_cached(
            max_x,
            min_y,
            max_y,
            current_x + step_x,
            step_x,
            step_y,
            cache,
          )
      }
    }
  }
}

fn check_y_range_cached(
  max_y: Int,
  x: Int,
  current_y: Int,
  step_y: Int,
  cache: PolygonCache,
) -> Bool {
  case current_y > max_y {
    True -> True
    False -> {
      let point = Point(x, current_y)
      let valid = is_valid_point_cached(point, cache)
      case valid {
        False -> False
        True ->
          check_y_range_cached(max_y, x, current_y + step_y, step_y, cache)
      }
    }
  }
}

pub fn find_largest_rectangle_in_polygon(points: List(Point)) -> Int {
  let #(min_x, max_x, min_y, max_y) = compute_bounds(points)

  let cache =
    PolygonCache(
      points: points,
      points_set: set.from_list(points),
      edges: make_edge_pairs(points),
      min_x: min_x,
      max_x: max_x,
      min_y: min_y,
      max_y: max_y,
    )

  find_largest_in_polygon_helper(points, points, cache, 0)
}

// Optimisation: traiter les points par batches pour améliorer la localité du cache
fn find_largest_in_polygon_helper(
  all_points: List(Point),
  remaining: List(Point),
  cache: PolygonCache,
  max_area: Int,
) -> Int {
  case remaining {
    [] -> max_area
    [p1, ..rest] -> {
      // Optimisation: calculer l'aire maximale possible avec p1
      let max_possible_area = {
        let Point(x1, y1) = p1
        let max_width =
          int.max(
            int.absolute_value(cache.max_x - x1),
            int.absolute_value(cache.min_x - x1),
          )
        let max_height =
          int.max(
            int.absolute_value(cache.max_y - y1),
            int.absolute_value(cache.min_y - y1),
          )
        { max_width + 1 } * { max_height + 1 }
      }

      // Si même le meilleur rectangle possible avec p1 est <= max_area, skip
      case max_possible_area <= max_area {
        True ->
          find_largest_in_polygon_helper(all_points, rest, cache, max_area)
        False -> {
          let areas =
            list.filter_map(all_points, fn(p2) {
              case p1 == p2 {
                True -> Error(Nil)
                False -> {
                  let area = rectangle_area(p1, p2)
                  case area <= max_area {
                    True -> Error(Nil)
                    False -> {
                      case rectangle_in_polygon_cached(p1, p2, cache) {
                        True -> Ok(area)
                        False -> Error(Nil)
                      }
                    }
                  }
                }
              }
            })

          let local_max = list.fold(areas, max_area, int.max)

          find_largest_in_polygon_helper(all_points, rest, cache, local_max)
        }
      }
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
