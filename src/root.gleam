import gleam/dict.{type Dict}

pub type Mods {
  Hub(HubBody)
  Fight(FightBody)
  Credit
}

pub type HubBody {
  HubBody(volume_animation_timer: Float)
}

pub type FightBody {
  FightBody(
    responses: Dict(String, FightResponse),
    hp: Float,
    required_press: String,
    initial_presses: Int,
    phases: List(Phase),
    press_counter: Int,
    // press_per_minute: Int,
    // press_per_mistake: Int,
  )
}

pub type Phase {
  Phase(buttons: String, max_press_count: Int)
}

pub type Identification {
  HubId
  FightId
  CreditId
}

pub type Msg {
  Keydown(String)
  // Dmg
  Frame(Float)
  Resize(Int, Int)
}

pub type Response =
  fn(Model) -> Model

type FightResponse =
  fn(FightBody, String) -> #(FightBody, TransitionFromFight)

pub type Model {
  Model(
    mod: Mods,
    volume: RangedInt,
    responses: Dict(#(Identification, String), Response),
    selected_level: RangedInt,
    program_duration: Float,
    viewport_width: Int,
    viewport_height: Int,
  )
}

pub type RangedInt {
  Range(val: Int, min: Int, max: Int)
}

pub fn update_range(range: RangedInt, change) {
  Range(..range, val: case range.val + change {
    val if val >= range.max -> range.max
    val if val <= range.min -> range.min
    val -> val
  })
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

pub type MovingPixel {
  Pixel(existence_time: Float, position: Position, trajectory: Position)
}

pub type TransitionFromFight {
  DoNothing
  ToHub
}

pub type Array(t)

pub type Position =
  #(Float, Float)

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50
