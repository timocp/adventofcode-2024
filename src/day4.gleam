import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import parse

pub fn part1(input: String) -> Int {
  let grid = parse.grid(input)

  grid
  |> dict.to_list
  |> list.map(fn(kv) { count_xmas(grid, kv.0) })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let grid = parse.grid(input)

  grid
  |> dict.to_list
  |> list.count(fn(kv) { is_cross_mas(grid, kv.0) })
}

type Dir {
  N
  NE
  E
  SE
  S
  SW
  W
  NW
}

fn count_xmas(grid: parse.Grid, at: #(Int, Int)) -> Int {
  [N, NE, E, SE, S, SW, W, NW]
  |> list.count(fn(dir) { is_xmas(grid, at, dir, 0) })
}

const xmas = "XMAS"

fn is_xmas(grid: parse.Grid, at: #(Int, Int), dir: Dir, index: Int) -> Bool {
  let letter = string.slice(xmas, index, 1)
  case get_at(grid, at) == letter {
    True ->
      case index {
        3 -> True
        _ -> is_xmas(grid, next_cell(at, dir), dir, index + 1)
      }
    False -> False
  }
}

fn next_cell(from: #(Int, Int), dir: Dir) -> #(Int, Int) {
  case dir {
    N -> #(from.0, from.1 - 1)
    NE -> #(from.0 + 1, from.1 - 1)
    E -> #(from.0 + 1, from.1)
    SE -> #(from.0 + 1, from.1 + 1)
    S -> #(from.0, from.1 + 1)
    SW -> #(from.0 - 1, from.1 + 1)
    W -> #(from.0 - 1, from.1)
    NW -> #(from.0 - 1, from.1 - 1)
  }
}

fn is_cross_mas(grid: parse.Grid, at: #(Int, Int)) -> Bool {
  case get_at(grid, at) {
    "A" -> {
      let ne = get_at(grid, next_cell(at, NE))
      let se = get_at(grid, next_cell(at, SE))
      let sw = get_at(grid, next_cell(at, SW))
      let nw = get_at(grid, next_cell(at, NW))
      let diag1 = sw <> ne
      let diag2 = nw <> se

      { diag1 == "MS" || diag1 == "SM" } && { diag2 == "MS" || diag2 == "SM" }
    }
    _ -> False
  }
}

fn get_at(grid: parse.Grid, at: #(Int, Int)) -> String {
  case dict.get(grid, at) {
    Ok(value) -> value
    Error(_) -> ""
  }
}
