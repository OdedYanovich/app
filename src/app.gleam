import audio.{get_val}
import ffi/gleam/main.{
  init_game_loop, init_keydown_event, init_resize_event, set_storage,
}
import ffi/gleam/sound
import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/list
import gleam/result.{try}
import gleam/string
import initialization.{init}
import level.{levels}
import lustre.{dispatch}
import root.{
  type FightBody, type Identification, type Model, After, Before, Credit,
  CreditId, DoNothing, Fight, FightBody, FightId, Frame, Hub, HubBody, HubId,
  IntroductoryFight, IntroductoryFightId, Keydown, Model, Phase, Range, Resize,
  StableMod, ToHub, mod_transition_time,
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
              |> list.map(fn(sound) { sound.simple_play(sound) })
              model.sound_timer +. 2.0
            }
            False -> model.sound_timer
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
                mod: FightBody(
                    ..fight,
                    hp: fight.hp
                      -. 0.01
                      *. { program_duration -. model.program_duration },
                  )
                  |> Fight,
                sound_timer:,
              )
            IntroductoryFight(fight), _ ->
              Model(
                ..model,
                program_duration:,
                mod: FightBody(
                    ..fight,
                    hp: fight.hp
                      -. 0.01
                      *. { program_duration -. model.program_duration },
                  )
                  |> IntroductoryFight,
                sound_timer:,
              )
            _, _ -> Model(..model, program_duration:, sound_timer:)
          }
        }
        Keydown(latest_key_press) -> {
          let latest_key_press = latest_key_press |> string.lowercase
          let morph_to = fn(model, id) {
            Model(
              ..model,
              mod_transition: Before(
                model.program_duration +. mod_transition_time,
                id,
              ),
            )
          }
          use <- guard(model.mod_transition != StableMod, model)
          case
            model.responses
            |> dict.get(#(model.mod |> id, latest_key_press))
          {
            Ok(response) -> response(model)
            Error(_) ->
              case model.mod {
                Fight(fight) ->
                  case fight_response(fight, latest_key_press) {
                    #(_, ToHub) ->
                      Model(
                        ..model,
                        selected_level: Range(
                          ..model.selected_level,
                          max: model.selected_level.max + 1,
                        ),
                      )
                      |> morph_to(HubId)
                    #(fight, _) -> Model(..model, mod: Fight(fight))
                  }
                IntroductoryFight(fight) ->
                  case fight_response(fight, latest_key_press) {
                    #(_, ToHub) ->
                      Model(
                        ..model,
                        responses: model.responses
                          |> dict.insert(#(FightId, "z"), morph_to(_, HubId)),
                      )
                      |> morph_to(HubId)
                    #(fight, _) -> Model(..model, mod: IntroductoryFight(fight))
                  }

                _ -> model
              }
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

fn fight_response(fight: FightBody, latest_key_press: String) {
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
}

fn pair(a, b) {
  #(a, b)
}

fn id(mod) {
  case mod {
    Hub(_) -> HubId
    Fight(_) -> FightId
    Credit -> CreditId
    IntroductoryFight(_) -> IntroductoryFightId
  }
}

pub fn morphism(model: Model, mod: Identification) -> Model {
  let after = fn(mod) {
    Model(
      ..model,
      mod:,
      mod_transition: After(model.program_duration +. mod_transition_time),
    )
  }
  case mod {
    HubId -> 0.0 |> HubBody |> Hub |> after
    FightId -> {
      set_storage("selected_level", model.selected_level |> get_val)
      let phases = model.selected_level.val |> levels
      let assert [phase, ..other_phses] = phases
      let assert Ok(#(required_press, other_buttons)) =
        string.pop_grapheme(phase.buttons)
      FightBody(
        hp: 5.0,
        initial_presses: 20,
        phases: [Phase(..phase, buttons: other_buttons <> required_press)]
          |> list.append(other_phses),
        press_counter: 0,
        required_press:,
      )
      |> Fight
      |> after
    }
    CreditId -> after(Credit)
    IntroductoryFightId -> panic
  }
}
