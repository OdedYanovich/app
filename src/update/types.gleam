import gleam/dict.{type Dict}

pub type Mods {
  Hub
  FightStart
  Fight
}

pub type Model {
  Model(
    mod: Mods,
    player_combo: List(String),
    required_combo: List(String),
    fight_character_set: List(String),
    volume: Int,
    actions: Dict(#(String, Mods), fn(Model) -> Model),
    hp: Int,
  )
}

pub type Msg {
  Key(String)
}
