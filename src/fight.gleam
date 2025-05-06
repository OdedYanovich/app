import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import level
import root.{
  type FightBody, type Model, type Progress, Change, Fight, FightBody, HubId,
  IntroductoryFight, Model, NorthEast, NorthWest, Progress, SouthEast, SouthWest,
  Stay, transition,
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
    progress.timestemps |> get_bpm |> float.round >= progress.required_bpm,
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

// Belong to groups
pub fn displayed_button(fight: FightBody) {
  case level.get_element(fight.level) {
    True -> "y"
    False -> "b"
  }
}

fn update(progress: Progress, timestemp, success) {
  let finish = fn(timestemps) {
    Progress(
      ..progress,
      timestemps: timestemps
        |> list.append([timestemp]),
      required_bpm: case progress.press_counter > progress.max_timestemps * 3 {
        True -> progress.required_bpm - 1
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
      |> echo
      progress.timestemps
      |> finish
      // |> echo
    },
  )
  progress.timestemps
  |> list.drop(1)
  |> finish
}

pub fn get_bpm(timestemps) {
  let assert [offset, ..timestemps] = timestemps
  let len = timestemps |> list.length |> int.to_float
  // let timestemps = timestemps |> list.map(fn(stemp) { stemp -. offset })
  // {
  //   use sum, stemp <- list.fold(timestemps, 0.0)
  //   sum +. stemp
  // }
  // /. len

  // {
  //   use #(sum, last), stemp <- list.fold(timestemps, #(0.0, offset))
  //   #(sum +. stemp -. last, stemp)
  // }.0
  // /. len
}

pub fn init_progress(level_id, starting_time) {
  Progress(
    timestemps: [starting_time],
    max_timestemps: level_id + 1,
    required_bpm: 4000,
    press_counter: 0,
  )
}
