import gleam/dict.{type Dict}
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
    last_mod: Mods,
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
    // image: Image,
    seed: seed.Seed,
    // effect: effect.Effect(Msg),
  )
}

pub type Image {
  Image(
    stationary_pixels: Array(Array(Bool)),
    moving_pixels: Array(Array(MovingPixel)),
    available_column_indices: Array(Int),
    columns_fullness: Array(Int),
    rows: Int,
    columns: Int,
    spawn_offset: Position,
    stopping_offset: Position,
    // full_columns: Int,
  )
}

pub type Array(t)

pub type Position =
  #(Float, Float)

pub type MovingPixel {
  Pixel(existence_time: Float, position: Position, trajectory: Position)
}

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50

// pub fn moving_pixel_spawn_offset() {
//   #(
//     pixel_spawn_offset.0 -. int.to_float({ image_rows * pixel_dimensions }),
//     pixel_spawn_offset.1 -. int.to_float({ image_columns * pixel_dimensions }),
//   )
// }

pub const hub_transition_key = "z"

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
