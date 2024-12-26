import gleam/list
import gleam/result
import gleam/string
import grid.{type Dir, type Grid, type Pos}

pub fn part1(input: String) -> Int {
  let #(grid, start) = input |> parse_input

  path_to_exit(grid, start, grid.N, [])
  |> list.unique
  |> list.length
}

fn path_to_exit(
  grid: Grid(Cell),
  pos: Pos,
  dir: Dir,
  path: List(Pos),
) -> List(Pos) {
  case grid.checked_get(grid, pos) {
    Ok(_cell) -> {
      let next_pos = grid.move(pos, dir)
      case grid.get(grid, next_pos) {
        Empty -> path_to_exit(grid, next_pos, dir, [pos, ..path])
        Obstacle -> path_to_exit(grid, pos, grid.right_90(dir), path)
      }
    }
    Error(_) -> {
      // off grid = exit
      path
    }
  }
}

type Cell {
  Empty
  Obstacle
}

fn parse_input(input: String) -> #(Grid(Cell), Pos) {
  let position_of_chars =
    input
    |> string.trim_end
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten

  let grid =
    position_of_chars
    |> list.map(fn(pos_char) {
      #(pos_char.0, case pos_char.1 {
        "." | "^" -> Empty
        "#" -> Obstacle
        _ -> panic as { "Invalid character " <> pos_char.1 }
      })
    })
    |> grid.from_list(Empty)

  let start =
    position_of_chars
    |> list.find(fn(pos_char) { pos_char.1 == "^" })
    |> result.map(fn(pos_char) { pos_char.0 })
    |> result.unwrap(#(0, 0))

  #(grid, start)
}
