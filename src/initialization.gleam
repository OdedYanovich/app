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
  IntroductoryFightId, Last5Levels, LastLevel, Model, MuteToggle, Next5Levels,
  NextLevel, NorthEast, NorthWest, Progress, Range, SouthEast, SouthWest,
  StableMod, Transition, transition, update_ranged_int,
  volume_buttons_and_changes,
}

pub fn init(_flags) {
  let fight =
    FightBody(
      hp: 65.0,
      hp_lose: False,
      initial_presses: 20,
      level: level.get(0),
      press_counter: 0,
      last_action_group: SouthWest,
      progress: fight.init_progress(0, 0.0),
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
          mod: FightBody(..fight, hp: fight.hp +. 8.0, hp_lose: True)
            |> IntroductoryFight,
        )
      }),
    ]
      |> dict.from_list,
    key_groups: { south_west }
      |> string.to_graphemes
      |> list.map(fn(button) { #(#(IntroductoryFightId, button), SouthWest) })
      |> dict.from_list,
    selected_level: get_storage("selected_level")
      |> Range(0, 80),
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    sounds: [0, 1, 2, 3],
    sound_timer: 0.0,
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
      #(#(HubId, Last5Levels), change_level(_, -5)),
      #(#(HubId, Next5Levels), change_level(_, 5)),
      #(#(HubId, MuteToggle), mute_toggle),
      #(#(HubId, Transition(FightId)), transition(_, FightId)),
      #(#(HubId, Transition(CreditId)), transition(_, CreditId)),
      #(#(FightId, Transition(HubId)), transition(_, HubId)),
      #(#(FightId, NorthEast), fight.progress(_, NorthEast)),
      #(#(FightId, SouthEast), fight.progress(_, SouthEast)),
      #(#(FightId, NorthWest), fight.progress(_, NorthWest)),
      #(#(FightId, SouthWest), fight.progress(_, SouthWest)),
      #(#(CreditId, Transition(HubId)), transition(_, HubId)),
      #(#(IntroductoryFightId, NorthEast), fight.progress(_, NorthEast)),
      #(#(IntroductoryFightId, SouthEast), fight.progress(_, SouthEast)),
      #(#(IntroductoryFightId, NorthWest), fight.progress(_, NorthWest)),
      #(#(IntroductoryFightId, SouthWest), fight.progress(_, SouthWest)),
    ],
  ]
  |> list.flatten
  |> dict.from_list
}

const south_west = "azsxdcfvgb"

fn grouped_keys() {
  let group_buttons = fn(mod_id) {
    [
      #("1q2w3e4r5t", NorthWest),
      #("8u9i0o-p=[", NorthEast),
      #("jnkml,;.'/", SouthEast),
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
      #(#(HubId, "j"), LastLevel),
      #(#(HubId, "k"), NextLevel),
      #(#(HubId, "h"), Last5Levels),
      #(#(HubId, "l"), Next5Levels),
      #(#(HubId, "o"), MuteToggle),
      #(#(HubId, "]"), Transition(FightId)),
      #(#(HubId, "["), Transition(CreditId)),
      #(#(CreditId, "["), Transition(HubId)),
      #(#(FightId, "]"), Transition(HubId)),
    ],
    group_buttons(IntroductoryFightId),
    group_buttons(FightId),
  ]
  |> list.flatten
  |> dict.from_list
}
