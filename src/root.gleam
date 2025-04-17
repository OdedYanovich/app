import gleam/dict.{type Dict}

pub type Mods {
  Hub(HubBody)
  Fight(FightBody)
  IntroductoryFight(FightBody)
  Credit
}

pub type HubBody {
  HubBody(volume_animation_timer: Float)
}

pub type FightBody {
  FightBody(
    hp: Float,
    // required_press: String,
    initial_presses: Int,
    buttons: List(String),
    indecies: List(Int),
    press_counter: Int,
    // press_per_minute: Int,
    // press_per_mistake: Int,
  )
}

pub type ModTransition {
  Before(timer: Float, new_mod: Identification)
  StableMod
  After(timer: Float)
}

pub type Identification {
  HubId
  FightId
  CreditId
  IntroductoryFightId
}

pub type Msg {
  Keydown(String)
  Frame(Float)
  Resize(Int, Int)
}

pub type Model {
  Model(
    mod: Mods,
    mod_transition: ModTransition,
    volume: RangedVal(Int),
    responses: Dict(#(Identification, String), fn(Model) -> Model),
    selected_level: RangedVal(Int),
    program_duration: Float,
    viewport_width: Int,
    viewport_height: Int,
    sounds: List(Int),
    sound_timer: Float,
  )
}

pub type RangedVal(t) {
  // Range(val: Int, min: Int, max: Int)
  Range(val: t, min: t, max: t)
}

pub fn update_ranged_int(range: RangedVal(Int), change) {
  Range(..range, val: case range.val + change {
    val if val >= range.max -> range.max
    val if val <= range.min -> range.min
    val -> val
  })
}

pub fn update_ranged_float(range: RangedVal(Float), change) {
  Range(..range, val: case range.val +. change {
    val if val >=. range.max -> range.max
    val if val <=. range.min -> range.min
    val -> val
  })
}

pub const volume_buttons_and_changes = [
  #("q", -25),
  #("w", -10),
  #("e", -5),
  #("r", -1),
  #("t", 1),
  #("y", 5),
  #("u", 10),
  #("i", 25),
]

pub const mod_transition_time = 400.0

pub type Image {
  Image(
    stationary_pixels: OldArray(OldArray(Bool)),
    moving_pixels: OldArray(OldArray(MovingPixel)),
    available_column_indices: OldArray(Int),
    columns_fullness: OldArray(Int),
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

pub type OldArray(t)

pub type Position =
  #(Float, Float)

pub const animation_end_time = 3000.0

pub const pixel_dimensions = 50
