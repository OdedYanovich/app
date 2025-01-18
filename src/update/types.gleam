import gleam/dict.{type Dict}

pub type Mods {
  Hub
  FightStart
  Fight
}

pub type Model {
  Model(
    mod: Mods,
    player_combo: String,
    required_combo: String,
    fight_character_set: List(String),
    volume: Int,
    actions: Dict(String, fn(Model) -> Model),
  )
}

pub type Msg {
  Key(String)
}
