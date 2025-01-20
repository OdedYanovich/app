import gleam/dict.{type Dict}
pub type Fighting {
  Before
  During
  Irrelevant
}

pub const hub_transition_key = "z"
pub type Mods {
  Hub
  Fight(Fighting)
}

pub type Model {
  Model(
    mod: Mods,
    player_combo: List(String),
    required_combo: List(String),
    fight_character_set: List(String),
    volume: Int,
    responses: Dict(#(String, Mods), fn(Model) -> Model),
    hp: Int,
  )
}

pub type Msg {
  Keyboard(String)
}
