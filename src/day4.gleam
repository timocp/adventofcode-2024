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
  case dict.get(grid, at) {
    Ok(value) -> {
      case value == letter {
        True -> {
          case index {
            3 -> True
            _ -> is_xmas(grid, next_cell(at, dir), dir, index + 1)
          }
        }
        False -> False
      }
    }
    Error(_) -> False
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
