import ffi/main
import funtil
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
  let old_progress = fight.progress
  let progress =
    {
      let action =
        case pressed_group {
          NorthWest | NorthEast -> True
          _ -> False
        }
        |> bool.exclusive_or(fight.direction_randomizer)
      let timestemps = old_progress.timestemps
      use <- bool.lazy_guard(
        fight.sequence_provider |> instraction != action,
        fn() {
          funtil.fix(fn(shorter, tail) {
            case tail {
              [head, ..tail] -> [head] |> list.append(shorter(tail))
              [] | [_] -> []
            }
          })(timestemps)
        },
      )
      use <- bool.guard(
        timestemps |> list.length < old_progress.max_timestemps,
        timestemps,
      )
      timestemps
      |> list.drop(1)
    }
    |> list.append([main.get_time()])
    |> Progress(
      timestemps: _,
      required_bpm: old_progress.required_bpm
        + case old_progress.press_counter > old_progress.max_timestemps * 2 {
        True -> 10
        False -> 0
      },
      press_counter: old_progress.press_counter + 1,
      max_timestemps: old_progress.max_timestemps,
    )
  use <- bool.guard(
    progress.timestemps |> get_bpm |> float.round <= progress.required_bpm
      && progress.timestemps |> list.length
      == old_progress.timestemps |> list.length,
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

pub fn get_bpm(timestemps) {
  let offset = timestemps |> list.first |> result.unwrap(0.0)
  let last = timestemps |> list.last |> result.unwrap(1.0)
  { last -. offset } /. int.to_float(list.length(timestemps) - 1)
}

pub fn init_progress(level_id) {
  Progress(
    timestemps: [main.get_time(), main.get_time() +. 1.0],
    max_timestemps: level_id + 2,
    required_bpm: 350,
    press_counter: 0,
  )
}
