import ffi/main
import gleam/dict.{type Dict}
import prng/seed

pub type Mods {
  Hub(HubBody)
  Fight(FightBody)
  IntroductoryFight(FightBody)
  Credit
}

pub type HubBody {
  HubBody(volume_timer: Float)
}

pub type FightBody {
  FightBody(
    sequence_provider: SequenceProvider,
    progress: Progress,
    last_action_group: ActionGroup,
    direction_randomizer: Bool,
  )
}

pub type SequenceProvider {
  SequenceProvider(
    // constants
    repeation_map: Int,
    msb: Int,
    // variables
    current_index: Int,
    loop_map: Int,
    repeation_accrued: Bool,
  )
}

pub type Mask {
  Mask(val: Int)
}

pub type BitRepresentation {
  BitRepresentation(val: Int)
}

pub type Progress {
  Progress(
    timestemps: List(Float),
    max_timestemps: Int,
    required_bpm: Int,
    press_counter: Int,
  )
}

pub type FightDirections {
  NorthEast
  SouthEast
  SouthWest
  NorthWest
  None
}

pub type ActionGroup {
  Attack(FightDirections)
  NextLevel
  Next5Levels
  Last5Levels
  LastLevel
  MuteToggle
  Transition(Identification)
  ChangeVolume(Int)
}

pub fn transition(model, id) {
  Model(
    ..model,
    mod_transition: Before(main.get_time() +. mod_transition_time, id),
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
  Frame
  Keydown(String)
  // Resize(Int, Int)
}

pub type Model {
  Model(
    mod: Mods,
    mod_transition: ModTransition,
    volume: RangedVal(Int),
    grouped_responses: Dict(#(Identification, ActionGroup), fn(Model) -> Model),
    key_groups: Dict(#(Identification, String), ActionGroup),
    selected_level: RangedVal(Int),
    seed: seed.Seed,
    // viewport_width: Int,
    // viewport_height: Int,
    // sounds: List(Int),
    // sound_timer: Float,
  )
}

pub type RangedVal(t) {
  Range(val: t, min: t, max: t)
}

pub type Initialized

pub fn update_ranged_int(range: RangedVal(Int), change) {
  // use float.clamp
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

pub const animation_end_time = 3000.0

pub const stored_level_id = "a"

pub const stored_volume_id = "b"
