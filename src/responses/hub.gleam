import gleam/dict
import gleam/int
import gleam/list
import responses/credit.{entering_credit}
import responses/fight.{entering_fight}

// import responses/hub.{change_volume, level_buttons, volume_buttons}
import root.{
  type Model, Credit, Fight, Level, Model, Phase, StartDmg, add_effect,
  all_command_keys, effectless,
}

// import prng/random
// let #(selected_column, seed) =
//   array.length(model.image.available_column_indices) - 1
//   |> random.int(0, _)
//   |> random.step(model.seed)

pub fn entering_hub() {
  volume_buttons
  |> list.map(fn(key_val) { #(key_val.0, change_volume(key_val.1, _)) })
  |> list.append([
    #("z", fn(model) {
      Model(
        ..model,
        mod: Fight,
        level: Level(
          buttons: all_command_keys
            |> level_buttons(model.selected_level),
          initial_presses: 20,
          phase: Phase(
            buttons: all_command_keys
              |> level_buttons(model.selected_level),
            press_per_minute: 2,
            press_per_mistake: 8,
            time: 1000.0,
          ),
          transition_rules: fn(_state) {
            Phase(
              buttons: all_command_keys
                |> level_buttons(model.selected_level),
              press_per_minute: 2,
              press_per_mistake: 8,
              time: 1000.0,
            )
          },
          press_counter: 0,
        ),
        required_combo: all_command_keys
          |> level_buttons(model.selected_level)
          |> list.shuffle,
        responses: entering_fight(entering_hub)
          |> dict.from_list,
      )
      |> add_effect(fn(dispatch) { dispatch(StartDmg(dispatch)) })
    }),
    #("c", fn(model) {
      Model(..model, mod: Credit, responses: entering_credit(entering_hub))
      |> effectless
    }),
  ])
  |> list.append([
    #("k", fn(model) {
      Model(..model, selected_level: case model.selected_level {
        1 -> 1
        n -> n - 1
      })
      |> effectless
    }),
  ])
  |> list.append([
    #("l", fn(model) {
      Model(..model, selected_level: case model.selected_level {
        n if n == model.unlocked_levels -> n
        n -> n + 1
      })
      |> effectless
    }),
  ])
}

pub const volume_buttons = [
  #("q", -25),
  #("w", -10),
  #("e", -5),
  #("r", -1),
  #("t", 1),
  #("y", 5),
  #("u", 10),
  #("i", 25),
]

fn change_volume(change, model: Model) {
  Model(
    ..model,
    timer: model.program_duration +. 500.0,
    volume: int.max(int.min(model.volume + change, 100), 0),
  )
  |> effectless
}

fn level_buttons(buttons, current_level) {
  buttons |> list.take(current_level + 1)
}
// type Level {
//   Level(button_count: Int, required_presses: Int)
// }
