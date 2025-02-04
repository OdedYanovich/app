import gleam/dict.{type Dict}
import gleam/option.{type Option}
import lustre/effect

pub type Mods {
  Hub
  Fight
}

pub type Msg {
  Keydown(String)
  StartDmg(fn(Msg) -> Nil)
  Dmg
  EndDmg
}

type Response =
  fn(Model) -> #(Model, effect.Effect(Msg))

pub type Model {
  Model(
    mod: Mods,
    latest_key_press: String,
    required_combo: List(String),
    fight_character_set: List(String),
    volume: Int,
    responses: Dict(String, Response),
    hp: Float,
    interval_id: Option(Int),
    unlocked_levels: Int,
    selected_level: Int,
  )
}
