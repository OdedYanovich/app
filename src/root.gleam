import gleam/dict.{type Dict}

pub type Fighting {
  Before
  During
  Irrelevant
}

pub type Mods {
  Hub
  Fight(Fighting)
}

pub type Model {
  Model(
    mod: Mods,
    latest_key_press: String,
    required_combo: List(String),
    fight_character_set: List(String),
    volume: Int,
    responses: Dict(String, fn(Model) -> Model),
    hp: Float,
  )
}

pub type Msg {
  Keydown(String)
  Dmg
}
