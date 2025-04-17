import gleam/dynamic/decode

@external(javascript, "./js/main.mjs", "startDrawing")
pub fn start_drawing() -> Nil

@external(javascript, "./js/main.mjs", "initGameLoop")
pub fn init_game_loop(callback: fn(Float) -> Nil) -> Nil

@external(javascript, "./js/main.mjs", "initKeydownEvent")
pub fn init_keydown_event(callback: fn(decode.Dynamic) -> any) -> Nil

@external(javascript, "./js/main.mjs", "initResizeEvent")
pub fn init_resize_event(callback: fn(Int, Int) -> Nil) -> Nil

@external(javascript, "./js/main.mjs", "sandCanvasSize")
pub fn get_viewport_size() -> #(Int, Int)

@external(javascript, "./js/main.mjs", "setStorage")
pub fn set_storage(key: String, val: Int) -> Nil

@external(javascript, "./js/main.mjs", "getStorage")
pub fn get_storage(key: String) -> Int
