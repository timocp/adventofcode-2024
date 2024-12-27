import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/string

pub fn part1(input: String) -> Int {
  parse_input(input)
  |> defrag
  |> checksum
}

type Block {
  Empty
  Filled(Int)
}

type Disk {
  // defragged part is reversed list of ids, because we only need to operate on the back
  Disk(defragged: List(Int), unsorted: Deque(Block))
}

fn defrag(disk: Disk) -> Disk {
  case deque.is_empty(disk.unsorted) {
    True -> disk
    False -> disk |> move_block |> defrag
  }
}

fn move_block(disk: Disk) -> Disk {
  case deque.pop_front(disk.unsorted) {
    Ok(#(Filled(f), rest1)) -> {
      Disk(defragged: [f, ..disk.defragged], unsorted: rest1)
    }
    Ok(#(Empty, rest1)) -> {
      case deque.pop_back(rest1) {
        Ok(#(Empty, rest2)) -> {
          Disk(
            defragged: disk.defragged,
            unsorted: rest2 |> deque.push_front(Empty),
          )
        }
        Ok(#(Filled(b), rest2)) -> {
          Disk(defragged: [b, ..disk.defragged], unsorted: rest2)
        }
        Error(_) -> {
          Disk(defragged: disk.defragged, unsorted: rest1)
        }
      }
    }
    Error(_) -> panic as "tried to move empty unsorted"
  }
}

fn checksum(disk: Disk) -> Int {
  disk.defragged
  |> list.reverse
  |> list.index_map(fn(id, i) { id * i })
  |> int.sum
}

fn debug_disk(disk: Disk) -> String {
  string.concat([
    disk.defragged
      |> list.reverse
      |> list.map(int.to_string)
      |> string.join(""),
    "|",
    disk.unsorted
      |> deque.to_list
      |> list.map(debug_block)
      |> string.join(""),
  ])
}

// only makes sense for the example, the real one has ids > 9
fn debug_block(block: Block) -> String {
  case block {
    Empty -> "."
    Filled(id) -> int.to_string(id)
  }
}

fn parse_input(input: String) -> Disk {
  Disk(
    defragged: [],
    unsorted: input
      |> string.trim_end
      |> string.to_graphemes
      |> list.index_map(fn(char, id) {
        case char_to_int(char) {
          a if a > 0 -> {
            list.range(1, char_to_int(char))
            |> list.map(fn(_) {
              case id % 2 == 0 {
                True -> Filled(id / 2)
                False -> Empty
              }
            })
          }
          _ -> []
        }
      })
      |> list.flatten
      |> deque.from_list,
  )
}

fn char_to_int(char: String) -> Int {
  case char {
    "0" -> 0
    "1" -> 1
    "2" -> 2
    "3" -> 3
    "4" -> 4
    "5" -> 5
    "6" -> 6
    "7" -> 7
    "8" -> 8
    "9" -> 9
    _ -> panic as "Unexpected input"
  }
}
