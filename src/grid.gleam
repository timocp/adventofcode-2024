//// Generic 2d grid

import gleam/dict

/// position is an x,y tuple
pub type Pos =
  #(Int, Int)

pub type Grid(g) {
  Grid(data: dict.Dict(Pos, g), default: g)
}

/// list: is tuple of #(Pos, value)
/// default: value that should be returned if an out of bounds position is read
pub fn from_list(list: List(#(Pos, g)), default: g) -> Grid(g) {
  Grid(data: list |> dict.from_list, default: default)
}

pub fn checked_get(grid: Grid(g), pos: Pos) -> Result(g, Nil) {
  dict.get(grid.data, pos)
}

pub fn get(grid: Grid(g), pos: Pos) -> g {
  case checked_get(grid, pos) {
    Ok(value) -> value
    Error(_) -> grid.default
  }
}

pub type Dir {
  N
  NE
  E
  SE
  S
  SW
  W
  NW
}

pub fn right_90(dir: Dir) {
  case dir {
    N -> E
    NE -> SE
    E -> S
    SE -> SW
    S -> W
    SW -> NW
    W -> N
    NW -> NE
  }
}

pub fn move(pos: Pos, dir: Dir) -> Pos {
  case dir {
    N -> #(pos.0, pos.1 - 1)
    NE -> #(pos.0 + 1, pos.1 - 1)
    E -> #(pos.0 + 1, pos.1)
    SE -> #(pos.0 + 1, pos.1 + 1)
    S -> #(pos.0, pos.1 + 1)
    SW -> #(pos.0 - 1, pos.1 + 1)
    W -> #(pos.0 - 1, pos.1)
    NW -> #(pos.0 - 1, pos.1 - 1)
  }
}
