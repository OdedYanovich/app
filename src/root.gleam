import gleam/dict.{type Dict}
import gleam/int
import gleam/option.{type Option}
import lustre/effect
import prng/seed

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
    stationary_pixels: List(Pixel),
    moving_pixels: List(Pixel),
    timer: Float,
    program_duration: Float,
    viewport_x: Int,
    viewport_y: Int,
    drawn_pixel_count: Int,
    drawn_pixels: List(Column),
    seed: seed.Seed,
  )
}

pub type Pixel {
  StationaryPixel(id: Int)
  MovingPixel(id: Int, time_since_creation: Float)
}

pub type Column {
  Column(stationary: Int, moving: List(Float))
}

pub const pixel_general_spawn_point = #(400.0, 800.0)

pub const pixel_general_stopping_point = #(400.0, 400.0)

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50

pub const image_rows = 8

pub const image_columns = 8

pub fn relative_position(pixel_id) {
  #(
    { pixel_id % image_rows } * pixel_dimensions |> int.to_float,
    { pixel_id / image_columns } * pixel_dimensions |> int.to_float,
  )
}

pub fn animation(start, end, time) {
  { end -. start } /. { animation_end_time /. { animation_end_time -. time } }
}

pub const hub_transition_key = "z"

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
