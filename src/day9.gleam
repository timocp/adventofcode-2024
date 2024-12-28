import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import vec.{type Vec}

pub fn part1(input: String) -> Int {
  parse_input(input)
  |> defrag
  |> checksum
}

pub fn part2(input: String) -> Int {
  let storage = to_storage(input)
  let max_id = { storage.file_loc |> vec.size } - 1

  storage
  |> defrag_2(max_id)
  |> checksum_2
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
            list.range(1, a)
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

// Storage for part 2 which is very different
// (If this works and is fast, could we reimplement part 1 using this, by
// mapping each block to a 1-sized file in a way that allows us to retain the
// IDs?)
type Storage {
  Storage(
    // list of free locations #(loc, size)
    free_list: List(#(Int, Int)),
    // current location of each file, keyed by file_id
    file_loc: Vec(Int),
    // size of each file, keyed by file_id
    file_size: Vec(Int),
  )
}

fn to_storage(input: String) -> Storage {
  // #(length, original_offset, physical_location)
  let input_data =
    input
    |> string.trim_end
    |> string.to_graphemes
    |> list.index_map(fn(char, offset) { #(char_to_int(char), offset) })
    |> list.map_fold(0, fn(acc, data) {
      let #(len, offset) = data
      #(acc + len, #(len, offset, acc))
    })
    |> pair.second

  let #(file_data, free_data) =
    input_data |> list.partition(fn(data) { data.1 % 2 == 0 })

  let file_loc =
    file_data
    |> list.map(fn(data) { data.2 })
    |> vec.from_list

  let file_size =
    file_data
    |> list.map(fn(data) { data.0 })
    |> vec.from_list

  let free_list =
    free_data
    |> list.filter(fn(data) { data.0 > 0 })
    |> list.map(fn(data) { #(data.2, data.0) })

  Storage(free_list: free_list, file_loc: file_loc, file_size: file_size)
}

fn defrag_2(storage: Storage, file_id: Int) -> Storage {
  //io.println_error("")
  //io.println_error("Current free list (loc,size):")
  //io.debug(storage.free_list)
  //io.println_error("Current file locations:")
  //storage.file_loc
  //|> vec.to_list
  //|> list.index_map(fn(f, i) { #(f, i) })
  //|> list.each(fn(x) {
  //  let #(loc, file_id) = x
  //  io.println_error(
  //    "  file_id "
  //    <> int.to_string(file_id)
  //    //<> " size "
  //    //<> int.to_string(storage.file_size |> vec.must_get(file_id))
  //    <> " is at "
  //    <> int.to_string(loc),
  //  )
  //})

  case file_id {
    -1 -> storage
    _ -> {
      let current_loc = storage.file_loc |> vec.must_get(file_id)
      let file_size = storage.file_size |> vec.must_get(file_id)

      case find_space(storage, current_loc, file_size) {
        Ok(#(free_loc, _free_size)) -> {
          //io.debug(#(
          //  "moving file_id",
          //  file_id,
          //  "size",
          //  file_size,
          //  "from",
          //  current_loc,
          //  "to",
          //  free_loc,
          //))

          defrag_2(
            Storage(
              // this is the hard bit
              free_list: storage.free_list
                |> list.filter_map(fn(entry) {
                  case entry.0 == free_loc, entry.1 == file_size {
                    True, True -> {
                      // This free entry is removed completely by the file move
                      Error(Nil)
                    }
                    True, False -> {
                      // This free entry needs to be shifted right and shunk as the file has moved into its position
                      Ok(#(entry.0 + file_size, entry.1 - file_size))
                    }
                    False, _ -> {
                      // drop this entry if it will never be used anymore
                      case entry.0 < current_loc {
                        True -> Ok(entry)
                        False -> Error(Nil)
                      }
                    }
                  }
                }),
              file_loc: storage.file_loc
                |> vec.update(file_id, free_loc),
              file_size: storage.file_size,
            ),
            file_id - 1,
          )
        }
        Error(_) -> {
          //io.debug(#("nowhere to move file_id", file_id, "size", file_size))
          defrag_2(storage, file_id - 1)
        }
      }
    }
  }
}

// give a file size, return the #(loc, size) entry from the free list which best matches it.
// Returns Error if no space is available to our left
fn find_space(
  storage: Storage,
  file_loc: Int,
  file_size: Int,
) -> Result(#(Int, Int), Nil) {
  storage.free_list
  |> list.find(fn(entry) { entry.1 >= file_size && entry.0 < file_loc })
}

fn checksum_2(storage: Storage) -> Int {
  list.range(0, { storage.file_loc |> vec.size } - 1)
  |> list.map(fn(file_id) {
    let loc = storage.file_loc |> vec.must_get(file_id)
    let size = storage.file_size |> vec.must_get(file_id)

    list.range(loc, loc + size - 1)
    |> list.map(fn(pos) { pos * file_id })
    |> int.sum
  })
  |> int.sum
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
