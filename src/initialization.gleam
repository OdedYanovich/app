import ffi/gleam/main.{get_viewport_size, init_js}
import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{None}
import gleam/result.{try}
import root.{
  type Model, Credit, Draw, EndDmg, Fight, Hub, Keydown, Level, Model, Phase,
  Resize, StartDmg, add_effect, all_command_keys, effectless, id,
}

pub fn init(_flags) {
  Model(
    mod: Hub(0.0),
    required_combo: [],
    volume: 50,
    responses: responses(),
    hp_lose_interval_id: None,
    unlocked_levels: 3,
    selected_level: 2,
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    // image: image.new(8, 8, #(400.0, 800.0), #(400.0, 400.0)),
  // seed: seed.random(),
  )
  |> add_effect(fn(dispatch) {
    use event <- init_js(
      fn(program_duration) { dispatch(Draw(program_duration)) },
      fn(viewport_x, viewport_y) { dispatch(Resize(viewport_x, viewport_y)) },
    )
    use #(key, repeat) <- try(
      decode.run(event, {
        use key <- decode.field("key", decode.string)
        use repeat <- decode.field("repeat", decode.bool)
        decode.success(#(key, repeat))
      }),
    )
    case repeat {
      True -> Ok(Nil)
      False -> dispatch(Keydown(key)) |> Ok
    }
  })
}

fn responses() {
  let meaningless_phase =
    Phase(buttons: [], press_per_minute: 0, press_per_mistake: 0, time: 0.0)
  let fight =
    Fight(
      fight_responses(),
      hp: 5.0,
      level: Level(
        buttons: [],
        initial_presses: 0,
        phase: meaningless_phase,
        transition_rules: fn(_state) { meaningless_phase },
        press_counter: 0,
      ),
    )
  volume_buttons
  |> list.map(fn(key_val) {
    #(#(Hub(0.0) |> id, key_val.0), change_volume(key_val.1, _))
  })
  |> list.append([
    #(#(Hub(0.0) |> id, "z"), fn(model) {
      model
      |> morph_to(fight)
      |> add_effect(fn(dispatch) { dispatch(StartDmg(dispatch)) })
    }),
    #(#(Hub(0.0) |> id, "c"), fn(model) {
      model |> morph_to(Credit) |> effectless
    }),
    #(#(Hub(0.0) |> id, "k"), change_level(_, -1)),
    #(#(Hub(0.0) |> id, "l"), change_level(_, 1)),
    #(#(fight |> id, "z"), fn(model) {
      model
      |> morph_to(Hub(0.0))
      |> add_effect(fn(dispatch) { dispatch(EndDmg) })
    }),
    #(#(Credit |> id, "z"), fn(model) {
      model
      |> morph_to(Hub(0.0))
      |> effectless
    }),
  ])
  |> dict.from_list
}

fn morph_to(model, mod) {
  case mod {
    Hub(_) -> Model(..model, mod: Hub(0.0))
    Fight(responses, hp, _level,) ->
      Model(
        ..model,
        mod: Fight(
          responses:,
          hp:,
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
        ),
        required_combo: all_command_keys
          |> level_buttons(model.selected_level)
          |> list.shuffle,
      )
    Credit -> Model(..model, mod:)
  }
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
  let assert Hub(timer) = model.mod
  let mod = Hub(timer +. 500.0)
  Model(..model, mod:, volume: int.max(int.min(model.volume + change, 100), 0))
  |> effectless
}

fn change_level(model, change) {
  Model(..model, selected_level: case model.selected_level + change {
    n if n >= model.unlocked_levels -> model.unlocked_levels
    n if n <= 0 -> 0
    n -> n
  })
  |> effectless
}

fn level_buttons(buttons, current_level) {
  buttons |> list.take(current_level + 1)
}

fn fight_responses() {
  list.map(all_command_keys, fn(key) {
    #(key, fn(model: Model, latest_key_press: String) {
      let assert Fight(responses, hp, level) = model.mod
      use <- guard(
        model.required_combo |> list.take(1) != [latest_key_press],
        Model(..model, mod: Fight(responses, hp -. 8.0, level))
          |> effectless,
      )
      use <- guard(
        hp >. 80.0,
        Model(
          ..model,
          unlocked_levels: model.unlocked_levels + 1,
          mod: Fight(responses:, hp: 5.0, level:),
        )
          |> morph_to(Hub(0.0))
          |> add_effect(fn(dispatch) { dispatch(EndDmg) }),
      )
      Model(
        ..model,
        mod: Fight(responses, hp +. 8.0, level),
        required_combo: model.required_combo
          |> list.drop(1)
          |> list.append(level.phase.buttons |> list.sample(1)),
        // seed:,
      )
      |> effectless
    })
  })
  |> dict.from_list
}
