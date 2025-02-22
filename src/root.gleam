import gleam/dict.{type Dict}
import gleam/int
import gleam/option.{type Option}
import lustre/effect

// import gleam/dynamic/decode
pub type Mods {
  Hub
  Fight
  Credit
}

pub type Msg {
  Keydown(String)
  StartDmg(fn(Msg) -> Nil)
  Dmg
  EndDmg
  Draw(Float)
  Resize(Int, Int)
}

type Response =
  fn(Model) -> #(Model, effect.Effect(Msg))

pub type Model {
  Model(
    mod: Mods,
    latest_key_press: String,
    required_combo: List(String),
    fight_character_set: List(String),
    volume: Int,
    responses: Dict(String, Response),
    hp: Float,
    interval_id: Option(Int),
    unlocked_levels: Int,
    selected_level: Int,
    stationary_pixels: List(StationaryPixel),
    moving_pixels: List(MovingPixel),
    timer: Float,
    program_duration: Float,
    viewport_x: Int,
    viewport_y: Int,
    drawn_pixel_count: Int,
  )
}

pub type StationaryPixel {
  Pixel(pos: Position, pixel_id: Int)
}

pub type MovingPixel {
  MPixel(pos: Position, pixel_id: Int, time_since_creation: Float)
}

pub const pixel_dimensions = 50

pub const pixel_rows_columns = 8

pub fn relative_position(pixel_id) {
  #(
    { pixel_id % pixel_rows_columns } * pixel_dimensions |> int.to_float,
    { pixel_id / pixel_rows_columns } * pixel_dimensions |> int.to_float,
  )
}

pub fn animation(start, end, duration) {
  { end -. start } /. duration
}

type Position =
  #(Float, Float)

pub type Direction {
  Direction(mov_x: Float, mov_y: Float, end_x: Float, end_t: Float)
}

pub const hub_transition_key = "z"

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
