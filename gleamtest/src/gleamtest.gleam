import birl as time
import birl/duration
import gleam/dict.{type Dict}
import gleam/float
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import glearray.{type Array}
import simplifile as file

pub fn main() {
  let time1 = time.now()
  let path = "../measurements.txt"
  let content = file.read(from: path)
  let file_read_time = time.difference(time.now(), time1)

  io.debug("File read time: ")
  file_read_time |> io.debug
  file_read_time |> duration.blur |> io.debug

  let assert Ok(raw_input) = content
  let time2 = time.now()
  let line_list = string.split(raw_input, on: "\n")
  let map = line_list |> list.fold(dict.new(), process_line)
  let parse_time = time.difference(time.now(), time2)

  io.debug("Parse time: ")
  parse_time |> io.debug
  parse_time |> duration.blur |> io.debug

  map |> dict.size() |> io.debug
}

// array version
// fn process_line(
//   map: Dict(String, Array(Float)),
//   s: String,
// ) -> Dict(String, Array(Float)) {
//   case string.split(s, ";") {
//     [] -> map
//     [city, temp] -> {
//       let temp_value = float.parse(temp)
//       case temp_value {
//         Ok(v) ->
//           case dict.get(map, city) {
//             Ok(readings) ->
//               dict.update(map, city, fn(x) {
//                 case x {
//                   Some(y) -> glearray.copy_push(y, v)
//                   None -> readings
//                 }
//               })
//             Error(_) -> dict.insert(map, city, [v] |> glearray.from_list)
//           }

//         Error(_) -> map
//       }
//     }
//     _ -> map
//   }
// }

// Linked list version
fn process_line(
  map: Dict(String, List(Float)),
  s: String,
) -> Dict(String, List(Float)) {
  case string.split(s, ";") {
    [] -> map
    [city, temp] -> {
      let temp_value = float.parse(temp)
      case temp_value {
        Ok(v) ->
          case dict.get(map, city) {
            Ok(readings) ->
              dict.update(map, city, fn(x) {
                case x {
                  Some(y) -> [v, ..y]
                  None -> readings
                }
              })
            Error(_) -> dict.insert(map, city, [v])
          }

        Error(_) -> map
      }
    }
    _ -> map
  }
}
