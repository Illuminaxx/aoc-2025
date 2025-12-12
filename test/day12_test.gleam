import day12
import gleam/list
import gleeunit/should

pub fn parse_shapes_test() {
  let input =
    "0:
###
##.
##.

1:
###
##.
.##"

  let #(shapes, _regions) = day12.parse_input(input)

  shapes
  |> list.length
  |> should.equal(2)

  case list.first(shapes) {
    Ok(shape) -> {
      let day12.Shape(id, _cells) = shape
      id |> should.equal(0)
    }
    Error(_) -> panic as "Expected at least one shape"
  }
}

pub fn parse_regions_test() {
  let input =
    "0:
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2"

  let #(_shapes, regions) = day12.parse_input(input)

  regions
  |> list.length
  |> should.equal(2)

  case list.first(regions) {
    Ok(region) -> {
      let day12.Region(width, height, presents) = region
      width |> should.equal(4)
      height |> should.equal(4)
      presents |> list.length |> should.equal(6)
    }
    Error(_) -> panic as "Expected at least one region"
  }
}

pub fn simple_example_test() {
  let input =
    "0:
##

1:
##

2x2: 2 0"

  let result = day12.solve_part1(input)
  result |> should.equal(1)
}

pub fn impossible_example_test() {
  let input =
    "0:
###

2x2: 2 0"

  let result = day12.solve_part1(input)
  result |> should.equal(0)
}

pub fn parse_full_example_test() {
  let input =
    "0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2"

  let #(shapes, regions) = day12.parse_input(input)

  shapes |> list.length |> should.equal(6)
  regions |> list.length |> should.equal(3)
}

pub fn quick_feasibility_simple_test() {
  let input =
    "0:
###

2x2: 5 0"

  let result = day12.solve_part1(input)
  result |> should.equal(0)
}

pub fn simple_region_success_test() {
  let input =
    "0:
##

2x2: 2 0"

  let result = day12.solve_part1(input)
  result |> should.equal(1)
}

pub fn shape_too_large_test() {
  let input =
    "0:
###

2x2: 1 0"

  let result = day12.solve_part1(input)
  result |> should.equal(0)
}

pub fn rotation_test() {
  let input =
    "0:
###

3x1: 1 0"

  let result = day12.solve_part1(input)
  result |> should.equal(1)
}

pub fn multiple_regions_test() {
  let input =
    "0:
##

2x2: 2 0
3x3: 4 0"

  let result = day12.solve_part1(input)
  result |> should.equal(2)
}

pub fn normalize_cells_test() {
  let input =
    "0:
.#
##

2x2: 1 0"

  let #(shapes, _) = day12.parse_input(input)

  case list.first(shapes) {
    Ok(shape) -> {
      let day12.Shape(_id, cells) = shape

      let min_x =
        cells
        |> list.map(fn(cell) {
          let #(x, _y) = cell
          x
        })
        |> list.fold(999, fn(acc, x) {
          case x < acc {
            True -> x
            False -> acc
          }
        })

      min_x |> should.equal(0)
    }
    Error(_) -> panic as "Expected at least one shape"
  }
}
