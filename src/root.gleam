import gleam/dict.{type Dict}
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
    stationary_pixels: List(Pixel),
    moving_pixels: List(#(Pixel, Direction)),
    timer: Float,
    viewport_x: Int,
    viewport_y: Int,
    drawn_pixel_count: Int,
  )
}

pub type Pixel {
  Pixel(pos_x: Float, pos_y: Float, count: Int)
}

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
