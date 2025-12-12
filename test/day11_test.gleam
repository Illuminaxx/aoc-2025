// test/day11_test.gleam
import day11
import gleam/dict
import gleam/set
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn parse_simple_graph_test() {
  let input =
    "you: a b
a: b
b: out"

  let graph = day11.parse_input(input)

  graph
  |> dict.get("you")
  |> should.be_ok
  |> should.equal(["a", "b"])

  graph
  |> dict.get("a")
  |> should.be_ok
  |> should.equal(["b"])

  graph
  |> dict.get("b")
  |> should.be_ok
  |> should.equal(["out"])
}

pub fn count_paths_simple_test() {
  let input = "you: out"

  let graph = day11.parse_input(input)
  let count = day11.count_paths(graph, "you", "out")

  count
  |> should.equal(1)
}

pub fn count_paths_multiple_test() {
  let input =
    "you: a b
a: out
b: out"

  let graph = day11.parse_input(input)
  let count = day11.count_paths(graph, "you", "out")

  count
  |> should.equal(2)
}

pub fn count_paths_intermediate_test() {
  let input =
    "you: a
a: b
b: out"

  let graph = day11.parse_input(input)
  let count = day11.count_paths(graph, "you", "out")

  count
  |> should.equal(1)
}

pub fn count_paths_same_node_test() {
  let input = "you: a"

  let graph = day11.parse_input(input)
  let count = day11.count_paths(graph, "you", "you")

  count
  |> should.equal(1)
}

pub fn count_paths_through_test() {
  let input =
    "svr: dac fft
dac: fft
fft: out"

  let graph = day11.parse_input(input)
  let must_visit = set.from_list(["dac", "fft"])
  let count = day11.count_paths_through(graph, "svr", "out", must_visit)

  count
  |> should.equal(1)
}

pub fn count_paths_complex_test() {
  let input =
    "you: a b
a: c d
b: c d
c: out
d: out"

  let graph = day11.parse_input(input)
  let count = day11.count_paths(graph, "you", "out")

  count
  |> should.equal(4)
}
