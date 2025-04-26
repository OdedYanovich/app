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
    level: Level,
    last_action_group: ActionGroup,
    // wanted_choice: Choice,
    initial_presses: Int,
    press_counter: Int,
    // press_per_minute: Int,
    // press_per_mistake: Int,
  )
}

pub type Level {
  Level(
    // Level constants
    repeation_map: Int,
    finale_index: Int,
    // Level variables
    current_index: Int,
    loop_index: Int,
    repeation_accrued: Bool,
    // finale_loop: Int,
  )
}

pub type ActionGroup {
  NorthEast
  SouthEast
  SouthWest
  NorthWest
  NextLevel
  LastLevel
  MuteToggle
  Transition(Identification)
  ChangeVolume(Int)
  None
}

pub fn transition(model, id) {
  Model(
    ..model,
    mod_transition: Before(model.program_duration +. mod_transition_time, id),
  )
}

pub type Choice {
  Stay
  Change
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
    grouped_responses: Dict(#(Identification, ActionGroup), fn(Model) -> Model),
    key_groups: Dict(#(Identification, String), ActionGroup),
    selected_level: RangedVal(Int),
    program_duration: Float,
    viewport_width: Int,
    viewport_height: Int,
    sounds: List(Int),
    sound_timer: Float,
  )
}

pub type RangedVal(t) {
  Range(val: t, min: t, max: t)
}

pub type Initialized

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

pub const animation_end_time = 3000.0
