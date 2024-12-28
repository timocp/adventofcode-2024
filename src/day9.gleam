import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import vec.{type Vec}

pub fn part1(input: String) -> Int {
  to_storage(input)
  |> split_files
  |> fn(pair) {
    let #(storage, file_id_map) = pair
    storage
    |> defrag
    |> checksum_3(fn(file_id) { vec.must_get(file_id_map, file_id) })
  }
}

pub fn part2(input: String) -> Int {
  to_storage(input)
  |> defrag
  |> checksum_3(fn(file_id) { file_id })
}

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

// So that part 1 can be done using part 2's algorithm:
// Map each multi-block file into single-block files, eg:
// ..111..  -> ..123..
// Free list is unchanged
//
// Return a Vec that is a map from the temporary file_id back to the original
// so that checksum can be calculated
fn split_files(storage: Storage) -> #(Storage, Vec(Int)) {
  // list of single-block replacement files
  // #(new_location, original_file_id)
  let new_file_locations =
    storage.file_loc
    |> vec.to_list
    |> list.index_map(fn(original_location, original_file_id) {
      let size = storage.file_size |> vec.must_get(original_file_id)
      list.range(0, size - 1)
      |> list.map(fn(offset) { #(original_location + offset, original_file_id) })
    })
    |> list.flatten

  #(
    Storage(
      free_list: storage.free_list,
      file_loc: new_file_locations
        |> list.map(fn(new_file) { new_file.0 })
        |> vec.from_list,
      file_size: new_file_locations |> list.map(fn(_) { 1 }) |> vec.from_list,
    ),
    new_file_locations |> list.map(fn(new_file) { new_file.1 }) |> vec.from_list,
  )
}

fn defrag(storage: Storage) -> Storage {
  let max_id = { storage.file_loc |> vec.size } - 1
  defrag_file(storage, max_id)
}

fn defrag_file(storage: Storage, file_id: Int) -> Storage {
  case file_id {
    -1 -> storage
    _ -> {
      let current_loc = storage.file_loc |> vec.must_get(file_id)
      let file_size = storage.file_size |> vec.must_get(file_id)

      case find_space(storage, current_loc, file_size) {
        Ok(#(free_loc, _free_size)) -> {
          defrag_file(
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
          defrag_file(storage, file_id - 1)
        }
      }
    }
  }
}

// given a file size, return the #(loc, size) entry from the free list which best matches it.
// Returns Error if no space is available to our left
fn find_space(
  storage: Storage,
  file_loc: Int,
  file_size: Int,
) -> Result(#(Int, Int), Nil) {
  storage.free_list
  |> list.find(fn(entry) { entry.1 >= file_size && entry.0 < file_loc })
}

// The callback maps the file_id back to an original. This is used by part 1
// which renumbers files when they are split into single blocks.
fn checksum_3(storage: Storage, file_id_map_fn: fn(Int) -> Int) {
  list.range(0, { storage.file_loc |> vec.size } - 1)
  |> list.map(fn(file_id) {
    let loc = storage.file_loc |> vec.must_get(file_id)
    let size = storage.file_size |> vec.must_get(file_id)

    list.range(loc, loc + size - 1)
    |> list.map(fn(pos) { pos * file_id_map_fn(file_id) })
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
