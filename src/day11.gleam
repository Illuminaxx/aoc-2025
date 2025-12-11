// src/day11.gleam
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Graph =
  Dict(String, List(String))

pub fn parse_input(input: String) -> Graph {
  input
  |> string.replace("\r\n", "\n")
  |> string.replace("\r", "\n")
  |> string.trim
  |> string.split("\n")
  |> list.fold(dict.new(), fn(graph, line) {
    let line = string.trim(line)
    case string.split_once(line, ": ") {
      Ok(#(device, outputs_str)) -> {
        let outputs =
          outputs_str
          |> string.split(" ")
          |> list.map(string.trim)
          |> list.filter(fn(s) { s != "" })
        dict.insert(graph, device, outputs)
      }
      Error(_) -> graph
    }
  })
}

pub fn count_paths(graph: Graph, from: String, to: String) -> Int {
  find_all_paths(graph, from, to, set.new())
}

fn find_all_paths(
  graph: Graph,
  current: String,
  target: String,
  visited: Set(String),
) -> Int {
  case current == target {
    True -> 1
    False -> {
      let new_visited = set.insert(visited, current)

      case dict.get(graph, current) {
        Ok(neighbors) -> {
          neighbors
          |> list.filter(fn(neighbor) { !set.contains(new_visited, neighbor) })
          |> list.fold(0, fn(count, neighbor) {
            count + find_all_paths(graph, neighbor, target, new_visited)
          })
        }
        Error(_) -> 0
      }
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  let graph = parse_input(input)

  let nodes_to_out =
    dict.fold(graph, 0, fn(count, _key, outputs) {
      case list.contains(outputs, "out") {
        True -> count + 1
        False -> count
      }
    })
  io.println("Nodes leading to 'out': " <> int.to_string(nodes_to_out))

  count_paths(graph, "you", "out")
}

pub fn solve_part2(input: String) -> Int {
  0
}
