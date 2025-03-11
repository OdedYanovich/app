import gleam/dynamic/decode.{type Dynamic}
import root.{type Array}

@external(javascript, "./jsffi.mjs", "newArray")
pub fn new_array(size: Int) -> Dynamic

// list.repeat(list.repeat(False, 8), 8)
// @external(javascript, "./jsffi.mjs", "new2dArray")
// fn new2d_array(rows: Int, columns: Int) -> Dynamic

@external(javascript, "./jsffi.mjs", "get")
pub fn get(array: Array, index: Int) -> Dynamic

@external(javascript, "./jsffi.mjs", "addOne")
pub fn add_one(array: Array, index: Int) -> Array
