import audio.{change_volume, mute_toggle}
import ffi/main.{get_storage, get_viewport_size}
import ffi/sound
import gleam/dict
import gleam/list
import level
import root.{
  type FightBody, type Model, Before, CreditId, FightBody, FightId, HubId,
  IntroductoryFight, IntroductoryFightId, Model, None, Range, StableMod,
  mod_transition_time, update_ranged_int, volume_buttons_and_changes,
}

pub fn init(_flags) {
  let #(indecies, buttons) = level.levels(0)
  let fight =
    FightBody(
      hp: 65.0,
      initial_presses: 20,
      buttons:,
      indecies:,
      press_counter: 0,
      last_button_group: None,
      wanted_action: None,
    )
  Model(
    mod: fight |> IntroductoryFight,
    mod_transition: StableMod,
    volume: Range(val: 111, min: 0, max: 100),
    responses: [
      #(#(IntroductoryFightId, level.required_button(fight)), fn(model) {
        sound.init_audio(0.1)
        Model(
          ..mute_toggle(model),
          responses: responses(),
          mod: FightBody(..fight, hp: fight.hp -. 8.0) |> IntroductoryFight,
        )
      }),
    ]
      |> dict.from_list,
    selected_level: case get_storage("selected_level") {
      9999 -> 1
      lv -> lv
    }
      |> Range(0, 3),
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    sounds: [0, 1, 2, 3],
    sound_timer: 0.0,
    // image: image.new(8, 8, #(400.0, 800.0), #(400.0, 400.0)),
  // seed: seed.random(),
  )
}

fn responses() -> dict.Dict(#(root.Identification, String), fn(Model) -> Model) {
  let change_level = fn(model, change) {
    Model(
      ..model,
      selected_level: update_ranged_int(model.selected_level, change),
    )
  }
  let transition = fn(model, id) {
    Model(
      ..model,
      mod_transition: Before(model.program_duration +. mod_transition_time, id),
    )
  }
  volume_buttons_and_changes
  |> list.map(fn(key_val) {
    #(#(HubId, key_val.0), change_volume(_, key_val.1))
  })
  |> list.append([
    #(#(HubId, "k"), change_level(_, -1)),
    #(#(HubId, "l"), change_level(_, 1)),
    #(#(HubId, "o"), mute_toggle),
    #(#(HubId, "]"), transition(_, FightId)),
    #(#(HubId, "["), transition(_, CreditId)),
    #(#(CreditId, "["), transition(_, HubId)),
  ])
  |> dict.from_list
}
