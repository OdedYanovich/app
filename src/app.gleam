import initialization.{init}
import lustre

import draw.{draw_frame}
import ffi/gleam/main.{end_hp_lose, start_hp_lose}
import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import root.{
  type Model, Dmg, Draw, EndDmg, Fight, Keydown, Model, Resize, StartDmg,
  effectless, id,
}
import view/view.{view}

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
