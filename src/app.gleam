import audio.{get_val}
import ffi/main.{
  get_time, init_game_loop, init_keydown_event, init_resize_event, set_storage,
}
import ffi/sound
import fight
import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/list
import gleam/result.{try}
import gleam/string
import initialization.{init}
import level
import lustre.{dispatch}
import root.{
  type FightBody, type Identification, type Model, After, Before, Credit,
  CreditId, Fight, FightBody, FightId, Frame, Hub, HubBody, HubId,
  IntroductoryFight, IntroductoryFightId, Keydown, Model, None, NorthEast,
  NorthWest, Resize, SouthEast, SouthWest, StableMod, mod_transition_time,
}
import view/view.{view}

pub fn main() {
  let assert Ok(update_the_model) =
    fn(model: Model, msg) {
      case msg {
        Frame(program_duration) -> {
          let sound_timer = case
            model.sound_timer <. model.program_duration
            && !audio.pass_the_limit(model.volume)
          {
            True -> {
              model.sounds
              |> list.map(fn(sound) { sound.play(sound) })
              model.sound_timer +. 2.0
            }
            False -> model.sound_timer
          }
          let update = fn(fight: FightBody) {
            use <- bool.guard(!fight.hp_lose, fight)
            use <- bool.guard(fight.hp <. 0.0, FightBody(..fight, hp: 0.0))
            FightBody(
              ..fight,
              hp: fight.hp
                -. 0.001
                *. { program_duration -. model.program_duration },
            )
          }
          case model.mod, model.mod_transition {
            _, Before(timer, id) if timer <. model.program_duration ->
              morphism(model, id)
            _, After(timer) if timer <. model.program_duration ->
              Model(..model, mod_transition: StableMod)
            Fight(fight), _ ->
              Model(
                ..model,
                program_duration:,
                mod: Fight(update(fight)),
                sound_timer:,
              )
            IntroductoryFight(fight), _ ->
              Model(
                ..model,
                program_duration:,
                mod: IntroductoryFight(update(fight)),
                sound_timer:,
              )
            _, _ -> Model(..model, program_duration:, sound_timer:)
          }
        }
        Keydown(latest_key_press) -> {
          let latest_key_press = latest_key_press |> string.lowercase
          use <- guard(model.mod_transition != StableMod, model)
          case
            model.key_groups
            |> dict.get(#(model.mod |> id, latest_key_press))
          {
            Ok(group) ->
              case
                model.grouped_responses
                |> dict.get(#(model.mod |> id, group))
              {
                Ok(response) -> response(model)
                Error(_) -> model
              }
            _ -> model
          }
        }
        Resize(viewport_width, viewport_height) ->
          Model(..model, viewport_width:, viewport_height:)
      }
    }
    |> lustre.simple(init, _, view)
    |> lustre.start("#app", Nil)
  init_game_loop(fn(program_duration) {
    update_the_model(dispatch(Frame(program_duration)))
  })
  init_resize_event(fn(viewport_x, viewport_y) {
    update_the_model(dispatch(Resize(viewport_x, viewport_y)))
  })
  use event <- init_keydown_event
  use #(key, repeat) <- try(
    decode.run(event, {
      use key <- decode.field("key", decode.string)
      use repeat <- decode.field("repeat", decode.bool)
      decode.success(#(key, repeat))
    }),
  )
  use <- guard(repeat, Ok(Nil))
  update_the_model(dispatch(Keydown(key))) |> Ok
}

fn id(mod) {
  case mod {
    Hub(_) -> HubId
    Fight(_) -> FightId
    Credit -> CreditId
    IntroductoryFight(_) -> IntroductoryFightId
  }
}

fn morphism(model: Model, mod: Identification) -> Model {
  let after = fn(mod) {
    Model(
      ..model,
      mod:,
      mod_transition: After(model.program_duration +. mod_transition_time),
    )
  }
  case mod {
    HubId ->
      case id(model.mod) {
        IntroductoryFightId ->
          Model(
            ..model,
            mod: 0.0 |> HubBody |> Hub,
            mod_transition: After(model.program_duration +. mod_transition_time),
            grouped_responses: model.grouped_responses
              // maybe remove
              |> dict.drop([
                #(IntroductoryFightId, NorthEast),
                #(IntroductoryFightId, SouthEast),
                #(IntroductoryFightId, NorthWest),
                #(IntroductoryFightId, SouthWest),
              ]),
          )
        _ -> 0.0 |> HubBody |> Hub |> after
      }
    FightId -> {
      let selected_level = model.selected_level |> get_val
      set_storage("selected_level", selected_level)
      FightBody(
        hp: 5.0,
        initial_presses: 20,
        hp_lose: True,
        press_counter: 0,
        level: selected_level |> level.get,
        last_action_group: None,
        progress: fight.init_progress(selected_level, model.program_duration),
      )
      |> Fight
      |> after
    }
    CreditId -> after(Credit)
    IntroductoryFightId -> panic
  }
}
