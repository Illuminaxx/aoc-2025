// src/day11.gleam
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Graph =
  Dict(String, List(String))

pub type Cache =
  Dict(#(String, String), Int)

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
  do_count_paths(graph, from, to, dict.new()).0
}

pub fn count_paths_through(
  graph: Graph,
  from: String,
  to: String,
  must_visit: Set(String),
) -> Int {
  let must_visit_list = set.to_list(must_visit)

  case must_visit_list {
    [node1, node2] -> {
      let order1 = {
        count_paths_memo(graph, from, node1)
        * count_paths_memo(graph, node1, node2)
        * count_paths_memo(graph, node2, to)
      }

      let order2 = {
        count_paths_memo(graph, from, node2)
        * count_paths_memo(graph, node2, node1)
        * count_paths_memo(graph, node1, to)
      }

      order1 + order2
    }
    _ -> {
      io.println("ERROR: Expected exactly 2 nodes to visit")
      0
    }
  }
}

fn count_paths_memo(graph: Graph, from: String, to: String) -> Int {
  do_count_paths(graph, from, to, dict.new()).0
}

fn do_count_paths(
  graph: Graph,
  start: String,
  end: String,
  memo: Cache,
) -> #(Int, Cache) {
  let key = #(start, end)

  case dict.get(memo, key) {
    Ok(count) -> #(count, memo)
    Error(_) -> {
      case start == end {
        True -> #(1, memo)
        False -> {
          let #(count, memo) = case dict.get(graph, start) {
            Ok(neighbors) -> {
              list.fold(neighbors, #(0, memo), fn(acc, neighbor) {
                let #(acc_count, acc_memo) = acc
                let #(neighbor_count, new_memo) =
                  do_count_paths(graph, neighbor, end, acc_memo)
                #(acc_count + neighbor_count, new_memo)
              })
            }
            Error(_) -> #(0, memo)
          }

          let new_memo = dict.insert(memo, key, count)
          #(count, new_memo)
        }
      }
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  let graph = parse_input(input)
  count_paths(graph, "you", "out")
}

pub fn solve_part2(input: String) -> Int {
  let graph = parse_input(input)
  let must_visit = set.from_list(["dac", "fft"])
  count_paths_through(graph, "svr", "out", must_visit)
}
