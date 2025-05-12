import ffi/main
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import root.{
  type Model, Fight, FightBody, HubId, IntroductoryFight, Model, NorthEast,
  NorthWest, Progress, transition,
}
import sequence_provider.{get_element as instraction, next_element}

pub fn update(model: Model, pressed_group) {
  let #(mod, fight) = case model.mod {
    Fight(fight) -> #(Fight, fight)
    IntroductoryFight(fight) -> #(IntroductoryFight, fight)
    _ -> panic
  }
  use <- bool.guard(fight.last_action_group == pressed_group, model)
  let progress = fight.progress
  let progress =
    {
      let action =
        case pressed_group {
          NorthWest | NorthEast -> True
          _ -> False
        }
        |> bool.exclusive_or(fight.direction_randomizer)
      let timestemps = progress.timestemps
      use <- bool.lazy_guard(
        fight.sequence_provider |> instraction != action,
        fn() {
          timestemps
          |> list.take(list.length(timestemps) - 2)
        },
      )
      use <- bool.guard(
        timestemps |> list.length < progress.max_timestemps,
        timestemps,
      )
      timestemps
      |> list.drop(1)
    }
    |> list.append([main.get_time()])
    |> Progress(
      timestemps: _,
      required_bpm: progress.required_bpm
        + case progress.press_counter > progress.max_timestemps * 2 {
        True -> 5
        False -> 0
      },
      press_counter: progress.press_counter + 1,
      max_timestemps: progress.max_timestemps,
    )
  use <- bool.guard(
    progress.timestemps |> get_bpm |> float.round <= progress.required_bpm,
    transition(model, HubId),
  )
  Model(
    ..model,
    mod: FightBody(
        ..fight,
        sequence_provider: fight.sequence_provider
          |> next_element,
        last_action_group: pressed_group,
        progress:,
      )
      |> mod,
  )
}

fn get_bpm(timestemps) {
  let offset = timestemps |> list.first |> result.unwrap(0.0)
  let last = timestemps |> list.last |> result.unwrap(0.0)
  { last -. offset } /. int.to_float(list.length(timestemps) - 1)
}

pub fn init_progress(level_id) {
  Progress(
    timestemps: [main.get_time()],
    max_timestemps: level_id + 2,
    required_bpm: 350,
    press_counter: 0,
  )
}
