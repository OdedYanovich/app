//import ffi/gleam/damage.{set_damage_event}
import ffi/gleam/main.{init_game_loop, init_keydown_event, init_resize_event}
import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/result.{try}
import gleam/string
import initialization.{init, morph_to}
import lustre.{dispatch}
import root.{
  type Model, Credit, CreditId, Fight, FightBody, FightId, Frame, Hub, HubId,
  Keydown, Model, Range, Resize, ToHub,
}
import view/view.{view}

pub fn main() {
  let assert Ok(update_the_model) =
    fn(model: Model, msg) {
      case msg {
        Frame(program_duration) ->
          case model.mod {
            Fight(fight) ->
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
              )
            _ -> Model(..model, program_duration:)
          }
        Keydown(latest_key_press) -> {
          let latest_key_press = latest_key_press |> string.lowercase
          case
            model.responses
            |> dict.get(#(model.mod |> id, latest_key_press))
          {
            Ok(response) -> response(model)
            Error(_) ->
              case model.mod {
                Fight(fight) ->
                  case fight.responses |> dict.get(latest_key_press) {
                    Ok(response) -> {
                      case response(fight, latest_key_press) {
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
                    }
                    Error(_) -> model
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
  // set_damage_event(fn() { update_the_model(dispatch(Dmg)) })
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
  }
}
