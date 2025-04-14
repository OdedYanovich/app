import audio.{change_volume, mute_toggle}
import ffi/gleam/main.{get_storage, get_viewport_size}
import gleam/dict
import gleam/list
import root.{
  type FightBody, type Model, Before, CreditId, FightBody, FightId, HubId,
  IntroductoryFight, IntroductoryFightId, Model, Phase, Range, StableMod,
  mod_transition_time, update_range, volume_buttons_and_changes,
}

pub fn init(_flags) {
  Model(
    mod: FightBody(
      hp: 65.0,
      initial_presses: 20,
      phases: [Phase(buttons: "td", max_press_count: -1)],
      press_counter: 0,
      required_press: "d",
    )
      |> IntroductoryFight,
    mod_transition: StableMod,
    volume: Range(val: 121, min: 0, max: 100),
    responses: [
      #(#(IntroductoryFightId, "d"), fn(model) {
        Model(..mute_toggle(model), responses: responses())
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
    Model(..model, selected_level: update_range(model.selected_level, change))
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
    #(#(HubId, "z"), transition(_, FightId)),
    #(#(HubId, "c"), transition(_, CreditId)),
    #(#(CreditId, "c"), transition(_, HubId)),
  ])
  |> dict.from_list
}
