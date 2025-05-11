import ffi/main
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import level
import root.{
  type Model, Change, Fight, FightBody, HubId, IntroductoryFight, Model,
  NorthEast, NorthWest, Progress, SouthEast, SouthWest, Stay, transition,
}

pub fn update(model: Model, pressed_group) {
  let #(mod, fight) = case model.mod {
    Fight(fight) -> #(Fight, fight)
    IntroductoryFight(fight) -> #(IntroductoryFight, fight)
    _ -> panic
  }
  use <- bool.guard(fight.last_action_group == pressed_group, model)
  let choice = case pressed_group {
    NorthWest | NorthEast -> Change
    SouthWest | SouthEast -> Stay
    _ -> panic
  }
  let choice = case choice {
    // Randomize
    Stay -> False
    Change -> True
  }
  let add_stemp = fn(timestemps) {
    Progress(
      ..fight.progress,
      timestemps: timestemps
        |> list.append([main.get_time()]),
      required_bpm: fight.progress.required_bpm
        + case
          fight.progress.press_counter > fight.progress.max_timestemps * 2
        {
          True -> 5
          False -> 0
        },
      press_counter: fight.progress.press_counter + 1,
    )
  }
  use <- bool.lazy_guard(choice != level.get_element(fight.level), fn() {
    Model(
      ..model,
      mod: FightBody(
          ..fight,
          last_action_group: pressed_group,
          progress: fight.progress.timestemps
            |> list.take(list.length(fight.progress.timestemps) - 2)
            |> add_stemp,
        )
        |> mod,
    )
  })
  let progress = {
    use <- bool.lazy_guard(
      fight.progress.timestemps |> list.length == fight.progress.max_timestemps,
      fn() {
        fight.progress.timestemps
        |> add_stemp
      },
    )
    fight.progress.timestemps
    |> list.drop(1)
    |> add_stemp
  }
  use <- bool.guard(
    progress.timestemps |> get_bpm |> float.round <= progress.required_bpm,
    transition(model, HubId),
  )
  Model(
    ..model,
    mod: FightBody(
        level: fight.level |> level.next_element,
        last_action_group: pressed_group,
        progress:,
      )
      |> mod,
  )
}

pub fn get_bpm(timestemps) {
  let offset = timestemps |> list.first |> result.unwrap(0.0)
  let last = timestemps |> list.last |> result.unwrap(0.0)
  { last -. offset } /. int.to_float(list.length(timestemps) - 1)
}

pub fn init_progress(level_id, starting_time) {
  Progress(
    timestemps: [starting_time],
    max_timestemps: level_id + 2,
    required_bpm: 350,
    press_counter: 0,
  )
}
