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
    hp_lose_interval_id: Option(Int),
    unlocked_levels: Int,
    selected_level: Int,
    timer: Float,
    program_duration: Float,
    viewport_width: Int,
    viewport_height: Int,
    drawn_pixel_count: Int,
    stationary_pixels: List(List(Bool)),
    //optimization: BitMap
    moving_pixels: List(MovingPixel),
    seed: seed.Seed,
    full_columns: Int,
    to_be_drawn: List(Int),
    // effect: effect.Effect(Msg),
  )
}

pub type MovingPixel {
  Pixel(existence_time: Float, spawn_point: Int, changing_point: Int)
}

// pub type Column {
//   Column(stationary: List(Int), moving: List(Float))
// }

pub const pixel_spawn_offset = #(400.0, 800.0)

pub const pixel_stopping_offset = #(400.0, 400.0)

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50

pub const image_rows = 8

pub const image_columns = 8

pub fn moving_pixel_spawn_offset() {
  #(
    pixel_spawn_offset.0 -. int.to_float({ image_rows * pixel_dimensions }),
    pixel_spawn_offset.1 -. int.to_float({ image_columns * pixel_dimensions }),
  )
}

// pub fn difference_between_first_moving_and_stationary_pixel() {
//   image_rows * 4
// }

pub const hub_transition_key = "z"

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
