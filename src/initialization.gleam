import audio.{change_volume, mute_toggle}
import ffi/main.{get_storage, get_viewport_size}
import ffi/sound
import fight
import gleam/dict
import gleam/list
import gleam/string
import level
import root.{
  ChangeVolume, CreditId, FightBody, FightId, HubId, IntroductoryFight,
  IntroductoryFightId, LastLevel, Model, MuteToggle, NextLevel, None, NorthEast,
  NorthWest, Range, SouthEast, SouthWest, StableMod, Stay, Transition,
  transition, update_ranged_int, volume_buttons_and_changes,
}

pub fn init(_flags) {
  let fight =
    FightBody(
      hp: 65.0,
      initial_presses: 20,
      level: level.get_level(0),
      press_counter: 0,
      last_action_group: SouthWest,
      // wanted_choice: Stay,
    )
  Model(
    mod: fight |> IntroductoryFight,
    mod_transition: StableMod,
    volume: Range(val: 111, min: 0, max: 100),
    grouped_responses: [
      #(#(IntroductoryFightId, SouthWest), fn(model) {
        sound.init_audio(0.1)
        Model(
          ..mute_toggle(model),
          grouped_responses: grouped_responses(),
          key_groups: grouped_keys(),
          mod: FightBody(
              ..fight,
              hp: fight.hp -. 8.0,
              last_action_group: SouthEast,
            )
            |> IntroductoryFight,
        )
      }),
    ]
      |> dict.from_list,
    key_groups: { south_west }
      |> string.to_graphemes
      |> list.map(fn(button) { #(#(IntroductoryFightId, button), SouthWest) })
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

fn grouped_responses() {
  let change_level = fn(model, change) {
    Model(
      ..model,
      selected_level: update_ranged_int(model.selected_level, change),
    )
  }

  [
    volume_buttons_and_changes
      |> list.map(fn(key_val) {
        #(#(HubId, ChangeVolume(key_val.1)), change_volume(_, key_val.1))
      }),
    [
      #(#(HubId, LastLevel), change_level(_, -1)),
      #(#(HubId, NextLevel), change_level(_, 1)),
      #(#(HubId, MuteToggle), mute_toggle),
      #(#(HubId, Transition(FightId)), transition(_, FightId)),
      #(#(HubId, Transition(CreditId)), transition(_, CreditId)),
      #(#(CreditId, Transition(HubId)), transition(_, HubId)),
    ],
    [
      #(#(IntroductoryFightId, NorthEast), fight.progress(_, NorthEast)),
      #(#(IntroductoryFightId, SouthEast), fight.progress(_, SouthEast)),
      #(#(IntroductoryFightId, NorthWest), fight.progress(_, NorthWest)),
      #(#(IntroductoryFightId, SouthWest), fight.progress(_, SouthWest)),
    ],
  ]
  |> list.flatten
  |> dict.from_list
}

const south_west = "zaxscd"

fn grouped_keys() {
  let group_buttons = fn(mod_id) {
    [
      #("q1w2e3", NorthWest),
      #("r5t6y7", NorthEast),
      #("vgbhnj", SouthEast),
      #(south_west, SouthWest),
    ]
    |> list.map(fn(buttons_group) {
      buttons_group.0
      |> string.to_graphemes()
      |> list.map(fn(button) { #(#(mod_id, button), buttons_group.1) })
    })
    |> list.flatten
  }
  [
    volume_buttons_and_changes
      |> list.map(fn(key_val) {
        #(#(HubId, key_val.0), ChangeVolume(key_val.1))
      }),
    [
      #(#(HubId, "k"), LastLevel),
      #(#(HubId, "l"), NextLevel),
      #(#(HubId, "o"), MuteToggle),
      #(#(HubId, "]"), Transition(FightId)),
      #(#(HubId, "["), Transition(CreditId)),
      #(#(CreditId, "["), Transition(HubId)),
    ],
    group_buttons(IntroductoryFightId),
    group_buttons(FightId),
  ]
  |> list.flatten
  |> dict.from_list
}
