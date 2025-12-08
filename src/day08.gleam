import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Point3D {
  Point3D(x: Int, y: Int, z: Int)
}

pub type Edge {
  Edge(a: Point3D, b: Point3D, distance: Float)
}

pub fn parse_points(input: String) -> List(Point3D) {
  input
  |> string.replace("\r\n", "\n")
  |> string.trim
  |> string.split("\n")
  |> list.filter_map(parse_point)
}

fn parse_point(line: String) -> Result(Point3D, Nil) {
  case string.split(line, ",") {
    [x_str, y_str, z_str] -> {
      case int.parse(x_str), int.parse(y_str), int.parse(z_str) {
        Ok(x), Ok(y), Ok(z) -> Ok(Point3D(x, y, z))
        _, _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn distance(a: Point3D, b: Point3D) -> Float {
  let Point3D(x1, y1, z1) = a
  let Point3D(x2, y2, z2) = b

  let dx = int.to_float(x2 - x1)
  let dy = int.to_float(y2 - y1)
  let dz = int.to_float(z2 - z1)

  float.square_root(dx *. dx +. dy *. dy +. dz *. dz)
  |> result.unwrap(0.0)
}

fn generate_edges(points: List(Point3D)) -> List(Edge) {
  generate_edges_helper(points, [])
}

fn generate_edges_helper(points: List(Point3D), acc: List(Edge)) -> List(Edge) {
  case points {
    [] -> acc
    [p, ..rest] -> {
      let edges = list.map(rest, fn(q) { Edge(p, q, distance(p, q)) })
      generate_edges_helper(rest, list.append(acc, edges))
    }
  }
}

pub type UnionFind {
  UnionFind(parent: Dict(Point3D, Point3D), size: Dict(Point3D, Int))
}

fn init_union_find(points: List(Point3D)) -> UnionFind {
  let parent =
    list.fold(points, dict.new(), fn(acc, p) { dict.insert(acc, p, p) })

  let size =
    list.fold(points, dict.new(), fn(acc, p) { dict.insert(acc, p, 1) })

  UnionFind(parent, size)
}

fn find(uf: UnionFind, p: Point3D) -> #(UnionFind, Point3D) {
  let UnionFind(parent, _size) = uf

  case dict.get(parent, p) {
    Error(_) -> #(uf, p)
    Ok(par) -> {
      case par == p {
        True -> #(uf, p)
        False -> {
          let #(new_uf, root) = find(uf, par)
          let new_parent = dict.insert(new_uf.parent, p, root)
          #(UnionFind(new_parent, new_uf.size), root)
        }
      }
    }
  }
}

fn union(uf: UnionFind, a: Point3D, b: Point3D) -> #(UnionFind, Bool) {
  let #(uf1, root_a) = find(uf, a)
  let #(uf2, root_b) = find(uf1, b)

  case root_a == root_b {
    True -> #(uf2, False)

    False -> {
      let size_a = dict.get(uf2.size, root_a) |> result.unwrap(1)
      let size_b = dict.get(uf2.size, root_b) |> result.unwrap(1)

      case size_a >= size_b {
        True -> {
          let new_parent = dict.insert(uf2.parent, root_b, root_a)
          let new_size = dict.insert(uf2.size, root_a, size_a + size_b)
          #(UnionFind(new_parent, new_size), True)
        }
        False -> {
          let new_parent = dict.insert(uf2.parent, root_a, root_b)
          let new_size = dict.insert(uf2.size, root_b, size_a + size_b)
          #(UnionFind(new_parent, new_size), True)
        }
      }
    }
  }
}

fn connect_closest(points: List(Point3D), n: Int) -> UnionFind {
  let edges = generate_edges(points)

  let sorted_edges =
    list.sort(edges, fn(e1, e2) { float.compare(e1.distance, e2.distance) })

  let uf = init_union_find(points)

  connect_n_edges(sorted_edges, uf, n, 0)
}

fn connect_n_edges(
  edges: List(Edge),
  uf: UnionFind,
  target: Int,
  count: Int,
) -> UnionFind {
  case count >= target {
    True -> uf
    False -> {
      case edges {
        [] -> uf
        [Edge(a, b, _), ..rest] -> {
          let #(new_uf, _connected) = union(uf, a, b)

          connect_n_edges(rest, new_uf, target, count + 1)
        }
      }
    }
  }
}

fn get_circuit_sizes(uf: UnionFind, points: List(Point3D)) -> List(Int) {
  // Trouver tous les roots
  let roots =
    list.map(points, fn(p) {
      let #(_, root) = find(uf, p)
      root
    })

  let root_counts =
    list.fold(roots, dict.new(), fn(acc, root) {
      case dict.get(acc, root) {
        Ok(count) -> dict.insert(acc, root, count + 1)
        Error(_) -> dict.insert(acc, root, 1)
      }
    })

  dict.values(root_counts)
}

fn connect_until_one_circuit(
  edges: List(Edge),
  uf: UnionFind,
  points: List(Point3D),
) -> #(UnionFind, Option(Edge)) {
  case edges {
    [] -> #(uf, None)
    [edge, ..rest] -> {
      let Edge(a, b, _) = edge
      let #(new_uf, connected) = union(uf, a, b)

      case connected {
        False -> {
          connect_until_one_circuit(rest, new_uf, points)
        }
        True -> {
          let num_circuits = list.length(get_circuit_sizes(new_uf, points))

          case num_circuits {
            1 -> {
              #(new_uf, Some(edge))
            }
            _ -> {
              connect_until_one_circuit(rest, new_uf, points)
            }
          }
        }
      }
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  let points = parse_points(input)

  let uf = connect_closest(points, 1000)

  let sizes = get_circuit_sizes(uf, points)

  let sorted_sizes = list.sort(sizes, fn(a, b) { int.compare(b, a) })

  case list.take(sorted_sizes, 3) {
    [a, b, c] -> {
      a * b * c
    }
    _ -> {
      io.println("Not enough circuits!")
      0
    }
  }
}

pub fn solve_part2(input: String) -> Int {
  let points = parse_points(input)

  let edges = generate_edges(points)

  let sorted_edges =
    list.sort(edges, fn(e1, e2) { float.compare(e1.distance, e2.distance) })

  let uf = init_union_find(points)

  let #(_final_uf, last_edge) =
    connect_until_one_circuit(sorted_edges, uf, points)

  case last_edge {
    Some(Edge(Point3D(x1, _, _), Point3D(x2, _, _), _)) -> {
      io.println(
        "Last connection: " <> int.to_string(x1) <> " and " <> int.to_string(x2),
      )
      x1 * x2
    }
    None -> 0
  }
}

pub fn solve_part1_example(input: String, connections: Int) -> Int {
  let points = parse_points(input)

  io.println("Number of junction boxes: " <> int.to_string(list.length(points)))

  let uf = connect_closest(points, connections)

  let sizes = get_circuit_sizes(uf, points)

  io.println("Number of circuits: " <> int.to_string(list.length(sizes)))
  io.println(
    "Circuit sizes: "
    <> string.inspect(list.sort(sizes, fn(a, b) { int.compare(b, a) })),
  )

  // Trier par taille décroissante et prendre les 3 plus grands
  let sorted_sizes = list.sort(sizes, fn(a, b) { int.compare(b, a) })

  case list.take(sorted_sizes, 3) {
    [a, b, c] -> a * b * c
    _ -> 0
  }
}
