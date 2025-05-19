import audio.{change_volume, mute_toggle}
import ffi/main.{get_storage}
import ffi/sound
import fight
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import prng/seed
import root.{
  Attack, ChangeVolume, CreditId, FightBody, FightId, HubId, IntroductoryFight,
  IntroductoryFightId, Last5Levels, LastLevel, Model, MuteToggle, Next5Levels,
  NextLevel, NorthEast, NorthWest, Range, SouthEast, SouthWest, 
  Transition, stored_level_id, stored_volume_id, transition, update_ranged_int,
  volume_buttons_and_changes,
  ToMod
}
import sequence_provider

pub fn init(_flags) {
  let #(sequence_provider, clue) = sequence_provider.get(0)
  let volume =
    get_storage(stored_volume_id)
    |> decode.run(decode.int)
    |> result.unwrap(111)
    |> Range(val: _, min: 0, max: 100)
  let fight =
    FightBody(
      sequence_provider:,
      last_action_group: Attack(south_east.1),
      progress: fight.init_progress(0),
      direction_randomizer: False,
      clue:,
    )
  Model(
    mod: fight
      |> IntroductoryFight,
    mod_transition: ToMod,
    volume:,
    grouped_responses: [
      #(#(IntroductoryFightId, Attack(SouthWest)), fn(model) {
        sound.init_audio({ volume.val |> int.to_float } /. 100.0)
        Model(
          ..mute_toggle(model),
          grouped_responses: grouped_responses(),
          key_groups: grouped_keys(),
          mod: FightBody(..fight, last_action_group: Attack(south_west.1))
            |> IntroductoryFight,
        )
      }),
    ]
      |> dict.from_list,
    key_groups: south_west.0
      |> string.to_graphemes
      |> list.map(fn(button) {
        #(#(IntroductoryFightId, button), Attack(SouthWest))
      })
      |> dict.from_list,
    selected_level: get_storage(stored_level_id)
      |> decode.run(decode.int)
      |> result.unwrap(1)
      |> Range(0, 80),
    seed: seed.random(),
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
      #(#(FightId, Attack(NorthEast)), fight.update(_, Attack(NorthEast))),
      #(#(FightId, Attack(SouthEast)), fight.update(_, Attack(SouthEast))),
      #(#(FightId, Attack(NorthWest)), fight.update(_, Attack(NorthWest))),
      #(#(FightId, Attack(SouthWest)), fight.update(_, Attack(SouthWest))),
      #(#(CreditId, Transition(HubId)), transition(_, HubId)),
      #(#(IntroductoryFightId, Attack(NorthEast)), fight.update(
        _,
        Attack(NorthEast),
      )),
      #(#(IntroductoryFightId, Attack(SouthEast)), fight.update(
        _,
        Attack(SouthEast),
      )),
      #(#(IntroductoryFightId, Attack(NorthWest)), fight.update(
        _,
        Attack(NorthWest),
      )),
      #(#(IntroductoryFightId, Attack(SouthWest)), fight.update(
        _,
        Attack(SouthWest),
      )),
    ],
  ]
  |> list.flatten
  |> dict.from_list
}

pub const north_west = #("1q2w3e4r5t", NorthWest)

pub const south_west = #("azsxdcfvgb", SouthWest)

pub const north_east = #("8u9i0o-p=[", NorthEast)

pub const south_east = #("jnkml,;.'/", SouthEast)

fn grouped_keys() {
  let group_buttons = fn(mod_id) {
    [north_west, north_east, south_east, south_west]
    |> list.map(fn(buttons_group) {
      buttons_group.0
      |> string.to_graphemes()
      |> list.map(fn(button) { #(#(mod_id, button), Attack(buttons_group.1)) })
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
