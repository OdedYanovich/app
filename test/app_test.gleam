import array
import gleam/io

pub fn main() {
  let arr = array.create(3, fn(index) { index })

  arr
  // |> array.map(fn(element, index) { element * index })
  // |> array.iter(fn(element, index) {
  //   Nil
  // })
  // |> array.get(7)
  |> array.push(7)
  |> array.push(9)
  // |> array.pop_back
  |> array.splice(2, 2)
  // |> array.length
  |> io.debug
}
