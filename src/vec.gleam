//// A 1d vector backed by a dict keyed by integer index

import gleam/dict.{type Dict}
import gleam/int
import gleam/list

pub type Vec(g) {
  Vec(data: Dict(Int, g))
}

pub fn from_list(list: List(g)) {
  list
  |> list.index_map(fn(value, i) { #(i, value) })
  |> dict.from_list
  |> Vec
}

pub fn to_list(vec: Vec(g)) -> List(g) {
  vec.data
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(i_v) { i_v.1 })
}

pub fn checked_get(vec: Vec(g), index: Int) -> Result(g, Nil) {
  dict.get(vec.data, index)
}

pub fn get(vec: Vec(g), index: Int, default: g) -> g {
  case checked_get(vec, index) {
    Ok(value) -> value
    Error(_) -> default
  }
}

pub fn must_get(vec: Vec(g), index: Int) -> g {
  case checked_get(vec, index) {
    Ok(value) -> value
    Error(_) -> panic as "vec.must_get called with missing index"
  }
}

pub fn size(vec: Vec(g)) -> Int {
  dict.size(vec.data)
}

pub fn update(vec: Vec(g), index: Int, value: g) -> Vec(g) {
  Vec(data: vec.data |> dict.insert(index, value))
}
