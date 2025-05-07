import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import level
import root.{
  type Model, type Progress, Change, Fight, FightBody, HubId, IntroductoryFight,
  Model, NorthEast, NorthWest, Progress, SouthEast, SouthWest, Stay, transition,
}

pub fn progress(model: Model, pressed_group) {
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
  let progress =
    fight.progress
    |> update(model.program_duration, choice == level.get_element(fight.level))
  use <- bool.guard(
    choice != level.get_element(fight.level),
    Model(
      ..model,
      mod: FightBody(
          ..fight,
          last_action_group: pressed_group,
          hp: fight.hp -. 4.0,
          progress:,
        )
        |> mod,
    ),
  )
  use <- bool.guard(
    progress.timestemps |> get_bpm |> float.round <= progress.required_bpm,
    transition(model, HubId),
  )
  Model(
    ..model,
    mod: FightBody(
        ..fight,
        hp: fight.hp +. 4.0,
        level: fight.level |> level.next_element,
        last_action_group: pressed_group,
        progress:,
      )
      |> mod,
  )
}

fn update(progress: Progress, timestemp, success) {
  let finish = fn(timestemps) {
    Progress(
      ..progress,
      timestemps: timestemps
        |> list.append([timestemp]),
      required_bpm: case progress.press_counter > progress.max_timestemps * 2 {
        True -> progress.required_bpm + 10
        False -> progress.required_bpm
      },
      press_counter: progress.press_counter + 1,
    )
  }
  use <- bool.lazy_guard(!success, fn() {
    progress.timestemps
    |> list.take(list.length(progress.timestemps) - 2)
    |> finish
  })
  use <- bool.lazy_guard(
    progress.timestemps |> list.length <= progress.max_timestemps,
    fn() {
      progress.timestemps
      |> get_bpm
      progress.timestemps
      |> finish
    },
  )
  progress.timestemps
  |> list.drop(1)
  |> finish
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
