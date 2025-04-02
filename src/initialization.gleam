import ffi/gleam/damage.{start_damage_event, stop_damage_event}
import ffi/gleam/main.{get_viewport_size}
import ffi/gleam/sound
import gleam/bool.{guard}
import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import level.{levels}
import root.{
  type FightBody, type Identification, type Model, Credit, CreditId, DoNothing,
  Fight, FightBody, FightId, Hub, HubBody, HubId, Model, Phase, Range, ToHub,
  update_range,
}

pub fn init(_flags) {
  Model(
    mod: 0.0 |> HubBody |> Hub,
    volume: Range(val: 151, min: 0, max: 100),
    responses: responses(),
    selected_level: Range(2, 0, 3),
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    // image: image.new(8, 8, #(400.0, 800.0), #(400.0, 400.0)),
  // seed: seed.random(),
  )
}

fn responses() -> dict.Dict(#(root.Identification, String), fn(Model) -> Model) {
  volume_buttons_and_changes
  |> list.map(fn(key_val) {
    #(#(HubId, key_val.0), change_volume(_, key_val.1))
  })
  |> list.append([
    #(#(HubId, "k"), change_level(_, -1)),
    #(#(HubId, "l"), change_level(_, 1)),
    #(#(HubId, "o"), mute_toggle),
    #(#(HubId, "z"), morph_to(_, FightId)),
    #(#(HubId, "c"), morph_to(_, CreditId)),
    #(#(FightId, "z"), morph_to(_, HubId)),
    #(#(CreditId, "z"), morph_to(_, HubId)),
  ])
  |> dict.from_list
}

pub fn morph_to(model: Model, mod: Identification) -> Model {
  case mod {
    HubId -> {
      stop_damage_event()
      Model(..model, mod: 0.0 |> HubBody |> Hub)
    }
    FightId -> {
      start_damage_event()
      let phases = model.selected_level.val |> levels
      let all_buttons =
        phases
        |> list.fold("", fn(all_buttons, to_add) {
          all_buttons <> to_add.buttons
        })
      let assert [phase, ..other_phses] = phases
      let assert Ok(#(required_press, other_buttons)) =
        string.pop_grapheme(phase.buttons)
      Model(
        ..model,
        mod: FightBody(
            responses: fight_responses(all_buttons),
            hp: 5.0,
            initial_presses: 20,
            phases: [Phase(..phase, buttons: other_buttons <> required_press)]
              |> list.append(other_phses),
            press_counter: 0,
            required_press:,
          )
          |> Fight,
      )
    }
    CreditId -> Model(..model, mod: Credit)
  }
}

pub const volume_buttons_and_changes = [
  #("q", -25),
  #("w", -10),
  #("e", -5),
  #("r", -1),
  #("t", 1),
  #("y", 5),
  #("u", 10),
  #("i", 25),
]

fn change_volume(model: Model, change) {
  Model(
    ..model,
    mod: HubBody(model.program_duration +. 500.0) |> Hub,
    volume: case model.volume.val > model.volume.max {
      True -> {
        sound.play(
          { model.volume.val |> int.to_float }
          /. { model.volume.max |> int.to_float },
        )
        Range(
          ..model.volume,
          val: model.volume.val + change - model.volume.max - 1,
        )
      }
      False -> model.volume |> update_range(change)
    },
  )
}

fn mute_toggle(model: Model) {
  Model(..model, volume: case model.volume.val > model.volume.max {
    True -> {
      sound.play(
        { model.volume.val |> int.to_float }
        /. { model.volume.max |> int.to_float },
      )
      Range(..model.volume, val: model.volume.val - model.volume.max - 1)
    }
    False -> {
      sound.pause()
      Range(..model.volume, val: model.volume.val + model.volume.max + 1)
    }
  })
}

fn change_level(model, change) {
  Model(..model, selected_level: update_range(model.selected_level, change))
}

fn fight_responses(buttons) {
  list.map(buttons |> string.to_graphemes, fn(key) {
    #(key, fn(fight: FightBody, latest_key_press: String) {
      use <- guard(
        fight.required_press != latest_key_press,
        FightBody(..fight, hp: fight.hp -. 8.0) |> pair(DoNothing),
      )
      use <- guard(fight.hp >. 80.0, FightBody(..fight, hp: 5.0) |> pair(ToHub))
      let #(phases, required_press, press_counter) = case fight.phases {
        [current, next, ..rest]
          if fight.press_counter + 1 == current.max_press_count
        -> {
          let assert Ok(#(required_press, rest_of_buttons)) =
            string.pop_grapheme(next.buttons)
          #(
            [Phase(..next, buttons: rest_of_buttons <> required_press)]
              |> list.append(rest)
              |> list.append([current]),
            required_press,
            0,
          )
        }
        [current, ..rest] -> {
          let assert Ok(#(required_press, rest_of_buttons)) =
            string.pop_grapheme(current.buttons)
          #(
            [Phase(..current, buttons: rest_of_buttons <> required_press)]
              |> list.append(rest),
            required_press,
            fight.press_counter + 1,
          )
        }
        _ -> panic
      }
      FightBody(
        ..fight,
        hp: fight.hp +. 8.0,
        required_press:,
        press_counter:,
        phases:,
      )
      |> pair(DoNothing)
    })
  })
  |> dict.from_list
}

fn pair(a, b) {
  #(a, b)
}
