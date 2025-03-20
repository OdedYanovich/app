import draw.{draw_frame}
import ffi/gleam/main.{end_hp_lose, get_viewport_size, init_js, start_hp_lose}
import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import initialization.{init}
import lustre
import root.{
  type Model, Credit, CreditId, Dmg, Draw, EndDmg, Fight, FightId, Hub, HubId,
  Keydown, Model, Resize, StartDmg, effectless,
}
import view/view.{view}
import gleam/result.{try}
import gleam/dynamic/decode

pub fn main() {
  let assert Ok(_runtime) =
    fn(model, msg) {
      case msg {
        Draw(program_duration) ->
          draw_frame(model, program_duration) |> effectless
        Keydown(latest_key_press) -> {
          let latest_key_press = latest_key_press |> string.lowercase
          case
            model.responses
            |> dict.get(#(model.mod |> id, latest_key_press))
          {
            Ok(response) -> response(model)
            Error(_) ->
              case model.mod {
                Fight(responses, _hp, _rp, _ip, _b, _ph, _pc) ->
                  case responses |> dict.get(latest_key_press) {
                    Ok(response) -> response(model, latest_key_press)
                    Error(_) -> model |> effectless
                  }
                _ -> model |> effectless
              }
          }
        }
        Dmg -> {
          case model.mod {
            Fight(
              responses,
              hp,
              required_press,
              initial_presses,
              buttons,
              phases,
              press_counter,
            ) ->
              Model(
                ..model,
                mod: Fight(
                  responses:,
                  hp: hp -. 0.02,
                  required_press:,
                  initial_presses:,
                  buttons:,
                  phases:,
                  press_counter:,
                ),
              )

            _ -> model
          }
          |> effectless
        }
        StartDmg(dispatch) ->
          Model(
            ..model,
            hp_lose_interval_id: Some(start_hp_lose(fn() { dispatch(Dmg) })),
          )
          |> effectless
        EndDmg -> {
          end_hp_lose(model.hp_lose_interval_id |> option.unwrap(0))
          Model(..model, hp_lose_interval_id: None) |> effectless
        }
        Resize(viewport_width, viewport_height) ->
          Model(..model, viewport_width:, viewport_height:) |> effectless
      }
    }
    |> lustre.application(init, _, view)
    |> lustre.start("#app", Nil)
}

fn t(dispatch) {
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
}

fn id(mod) {
  case mod {
    Hub(_) -> HubId
    Fight(_, _, _, _, _, _, _) -> FightId
    Credit -> CreditId
  }
}
