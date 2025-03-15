import root.{type Array, type MovingPixel}

@external(javascript, "./ffi/array.mjs", "create")
pub fn create(size: Int, init: fn(index) -> t) -> Array(t)

@external(javascript, "./ffi/array.mjs", "map")
pub fn map(array: Array(t), callback: fn(element, index) -> t) -> Array(t)

@external(javascript, "./ffi/array.mjs", "iter")
pub fn iter(array: Array(t), callback: fn(element, index) -> Nil) -> Nil

/// If index >= length -> Nil
@external(javascript, "./ffi/array.mjs", "get")
fn internal_get(array: Array(t), index: Int) -> t

pub fn get(array: Array(t), index: Int) {
  let t: t = internal_get(array, index)
  t
}

@external(javascript, "./ffi/array.mjs", "set")
pub fn set(array: Array(t), index: Int, val: t) -> Array(t)

@external(javascript, "./ffi/array.mjs", "length")
pub fn length(array: Array(t)) -> Int

@external(javascript, "./ffi/array.mjs", "push")
pub fn push(array: Array(t), val: t) -> Array(t)

/// Empty array will be paired with Nil
@external(javascript, "./ffi/array.mjs", "popBack")
pub fn pop_back(array: Array(t)) -> #(Array(t), t)

@external(javascript, "./ffi/array.mjs", "splice")
pub fn splice(array: Array(t), index: Int, amount: Int) -> #(Array(t), Array(t))

// pub fn get(array: Array(t), index: Int) -> Option(t) {
//   decode.run(internal_get(array, index), dynamic)
//   case internal_get(array, index) {
//     undefined -> None
//     val -> Some(val)
//   }
// }
@external(javascript, "./ffi/image.mjs", "createNew")
pub fn create_image(rows: Int, columns: Int) -> Nil

@external(javascript, "./ffi/image.mjs", "addMovingPixel")
pub fn add_moving_pixel(column_index: Int, pixel: MovingPixel) -> Nil
// @external(javascript, "./ffi/array.mjs", "setLast")
// pub fn set_last(array: Array(t), val: t) -> Array(t)

// @external(javascript, "./ffi/array.mjs", "indexArray")
// pub fn index_array(size: Int) -> Array(Int)

// @external(javascript, "./ffi/array.mjs", "last")
// pub fn last(array: Array(t)) -> t
