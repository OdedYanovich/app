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
    level: Level,
    latest_key_press: String,
    required_combo: List(String),
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

pub type Level {
  Level(
    initial_presses: Int,
    buttons: List(String),
    phase: Phase,
    transition_rules: fn(Int) -> Phase,
    press_counter: Int,
  )
}

pub type Phase {
  Phase(
    press_per_minute: Int,
    press_per_mistake: Int,
    time: Float,
    buttons: List(String),
  )
}

pub type Array(t)

pub type Position =
  #(Float, Float)

pub type MovingPixel {
  Pixel(existence_time: Float, position: Position, trajectory: Position)
}

pub const all_command_keys = ["s", "d", "f", "j", "k", "l", "w", "i"]

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50

pub fn add_effect(responses, effect) {
  #(responses, effect.from(effect))
}

pub fn effectless(responses) {
  #(responses, effect.none())
}
// pub fn moving_pixel_spawn_offset() {
//   #(
//     pixel_spawn_offset.0 -. int.to_float({ image_rows * pixel_dimensions }),
//     pixel_spawn_offset.1 -. int.to_float({ image_columns * pixel_dimensions }),
//   )
// }
