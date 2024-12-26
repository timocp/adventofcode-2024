import gleam/int
import gleam/list
import gleam/string
import grid.{type Dir, type Grid, type Pos}
import parse

pub fn part1(input: String) -> Int {
  let grid: Grid(String) = parse_input(input)

  grid
  |> grid.to_list
  |> list.map(fn(kv) { count_xmas(grid, kv.0) })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let grid: Grid(String) = parse_input(input)

  grid
  |> grid.to_list
  |> list.count(fn(kv) { is_cross_mas(grid, kv.0) })
}

fn count_xmas(grid: Grid(String), at: Pos) -> Int {
  grid.all_directions |> list.count(fn(dir) { is_xmas(grid, at, dir, 0) })
}

const xmas = "XMAS"

fn is_xmas(grid: Grid(String), at: #(Int, Int), dir: Dir, index: Int) -> Bool {
  let letter = string.slice(xmas, index, 1)
  case grid.get(grid, at) == letter {
    True ->
      case index {
        3 -> True
        _ -> is_xmas(grid, grid.move(at, dir), dir, index + 1)
      }
    False -> False
  }
}

fn is_cross_mas(grid: Grid(String), at: Pos) -> Bool {
  case grid.get(grid, at) {
    "A" -> {
      let ne = grid.get(grid, grid.move(at, grid.NE))
      let se = grid.get(grid, grid.move(at, grid.SE))
      let sw = grid.get(grid, grid.move(at, grid.SW))
      let nw = grid.get(grid, grid.move(at, grid.NW))
      let diag1 = sw <> ne
      let diag2 = nw <> se

      { diag1 == "MS" || diag1 == "SM" } && { diag2 == "MS" || diag2 == "SM" }
    }
    _ -> False
  }
}

fn parse_input(input: String) -> Grid(String) {
  input
  |> parse.lines
  |> list.index_map(fn(line, y) {
    line |> string.split("") |> list.index_map(fn(char, x) { #(#(x, y), char) })
  })
  |> list.flatten
  |> grid.from_list("")
}
