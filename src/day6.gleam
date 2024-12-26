import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import grid.{type Dir, type Grid, type Pos}
import parse

pub fn part1(input: String) -> Int {
  let #(grid, start) = input |> parse_input

  path_to_exit(grid, start, grid.N, [])
  |> list.unique
  |> list.length
}

pub fn part2(input: String) -> Int {
  let #(grid, start) = input |> parse_input

  count_obstructions(grid, start, start, grid.N, set.new(), set.new())
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

fn count_obstructions(
  grid: Grid(Cell),
  start: Pos,
  pos: Pos,
  dir: Dir,
  seen: Set(#(Pos, Dir)),
  already_tried: Set(Pos),
) -> Int {
  let next_pos = grid.move(pos, dir)
  case grid.checked_get(grid, next_pos) {
    Ok(Empty) -> {
      case start == next_pos || set.contains(already_tried, next_pos) {
        True -> {
          // No obstruction allowed here
          0
        }
        False -> {
          let with_obstacle = grid.insert(grid, next_pos, Obstacle)
          case is_loop(with_obstacle, pos, dir, seen) {
            True -> 1
            False -> 0
          }
        }
      }
      + count_obstructions(
        grid,
        start,
        next_pos,
        dir,
        set.insert(seen, #(pos, dir)),
        set.insert(already_tried, next_pos),
      )
    }
    Ok(Obstacle) ->
      count_obstructions(
        grid,
        start,
        pos,
        grid.right_90(dir),
        seen,
        already_tried,
      )
    Error(_) -> 0
  }
}

// determine if this is a looping pos/dir given existing path
fn is_loop(grid: Grid(Cell), pos: Pos, dir: Dir, seen: Set(#(Pos, Dir))) -> Bool {
  case set.contains(seen, #(pos, dir)) {
    True -> {
      // Loop detected
      True
    }
    False -> {
      let next_pos = grid.move(pos, dir)
      case grid.checked_get(grid, next_pos) {
        Ok(Empty) -> is_loop(grid, next_pos, dir, set.insert(seen, #(pos, dir)))
        Ok(Obstacle) -> is_loop(grid, pos, grid.right_90(dir), seen)
        Error(_) -> {
          // Reached exit, no loop
          False
        }
      }
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
    |> parse.lines
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
