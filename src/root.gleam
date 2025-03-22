import gleam/dict.{type Dict}
import gleam/option.{type Option}

pub type Mods {
  Hub(volume_animation_timer: Float)
  Fight(
    responses: Dict(String, FightResponse),
    hp: Float,
    required_press: String,
    initial_presses: Int,
    // buttons: List(String),
    phases: List(Phase),
    press_counter: Int,
  )
  Credit
}


pub type Phase {
  Phase(
    buttons: String,
    // press_per_minute: Int,
    // press_per_mistake: Int,
    // time: Float,
    // next_phase: fn(Int) -> Int,
  )
}

pub type Identification {
  HubId
  FightId
  CreditId
}

pub type Msg {
  Keydown(String)
  Dmg
  Frame(Float)
  Resize(Int, Int)
}

pub type Response =
  fn(Model) -> Model

type FightResponse =
  fn(Model, String) -> Model

pub type Model {
  Model(
    mod: Mods,
    volume: Int,
    responses: Dict(#(Identification, String), Response),
    hp_lose_interval_id: Option(Int),
    unlocked_levels: Int,
    selected_level: Int,
    program_duration: Float,
    viewport_width: Int,
    viewport_height: Int,
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
  )
}

pub type Array(t)

pub type Position =
  #(Float, Float)

pub type MovingPixel {
  Pixel(existence_time: Float, position: Position, trajectory: Position)
}

// pub const all_command_keys = "sdfjklwi"//["s", "d", "f", "j", "k", "l", "w", "i"]

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50
