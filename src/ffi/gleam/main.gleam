import gleam/dynamic/decode

@external(javascript, "../main.mjs", "startDrawing")
pub fn start_drawing() -> Nil

@external(javascript, "../main.mjs", "init")
pub fn init_js(
  loop: fn(Float) -> Nil,
  resize: fn(Int, Int) -> Nil,
  keydown_event: fn(decode.Dynamic) -> any,
) -> Nil

@external(javascript, "../main.mjs", "sandCanvasSize")
pub fn get_viewport_size() -> #(Int, Int)

@external(javascript, "../main.mjs", "endHpLose")
pub fn end_hp_lose(id: Int) -> Nil

@external(javascript, "../main.mjs", "startHpLose")
pub fn start_hp_lose(handler: fn() -> any) -> Int
