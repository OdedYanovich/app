import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{try}
import gleam/string
import lustre/effect
import root.{
  type Model, type Msg, Dmg, Draw, EndDmg, Hub, Keydown, Model, Resize, StartDmg,
  add_effect, effectless,
}
import update/responses.{entering_hub}

@external(javascript, "../jsffi.mjs", "endHpLose")
fn end_hp_lose(id: Int) -> Nil

@external(javascript, "../jsffi.mjs", "startHpLose")
fn start_hp_lose(handler: fn() -> any) -> Int

pub fn update(model: Model, msg: Msg) {
  case msg {
    Keydown(key) -> {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> response(Model(..model, latest_key_press: key))
        Error(_) -> model |> effectless
      }
    }
    Dmg -> #(Model(..model, hp: model.hp -. 0.02), effect.none())
    StartDmg(dispatch) ->
      Model(..model, interval_id: Some(start_hp_lose(fn() { dispatch(Dmg) })))
      |> effectless
    EndDmg -> {
      end_hp_lose(model.interval_id |> option.unwrap(0))
      Model(..model, interval_id: None) |> effectless
    }
    Draw(time_elapsed) -> {
      start_drawing()
      model.particals |> list.map(draw)
      Model(
        ..model,
        particals: model.particals
          |> list.map(fn(partical) {
            #(
              partical.0 +. 0.005 *. time_elapsed,
              partical.1 +. 0.005 *. time_elapsed,
            )
          }),
        timer: case model.timer >. time_elapsed {
          True -> model.timer -. time_elapsed
          False -> 0.0
        },
      )
      |> effectless
    }
    Resize(viewport_x, viewport_y) ->
      Model(..model, viewport_x:, viewport_y:)
      |> effectless
  }
}

@external(javascript, "../jsffi.mjs", "init")
fn init_js(
  loop: fn(Float) -> Nil,
  resize: fn(Int, Int) -> Nil,
  keydown_event: fn(decode.Dynamic) -> any,
) -> Nil

@external(javascript, "../jsffi.mjs", "startDrawing")
fn start_drawing() -> Nil

@external(javascript, "../jsffi.mjs", "draw")
fn draw(particles: #(Float, Float)) -> Nil

@external(javascript, "../jsffi.mjs", "sandCanvasSize")
fn get_viewport_size() -> #(Int, Int)

pub fn init(_flags) {
  Model(
    mod: Hub,
    latest_key_press: "F",
    required_combo: [],
    fight_character_set: [],
    volume: 50,
    responses: entering_hub()
      |> dict.from_list,
    hp: 5.0,
    interval_id: None,
    unlocked_levels: 3,
    selected_level: 1,
    particals: [#(40.0, 20.0), #(80.0, 140.0), #(100.0, 280.0)],
    timer: 0.0,
    viewport_x: get_viewport_size().0,
    viewport_y: get_viewport_size().1,
  )
  |> add_effect(fn(dispatch) {
    use event <- init_js(
      fn(time_elapsed) { dispatch(Draw(time_elapsed)) },
      fn(viewport_x, viewport_y) { dispatch(Resize(viewport_x, viewport_y)) },
    )
    use #(key, repeat) <- try(
      decode.run(event, {
        use key <- decode.field("key", decode.string)
        use repeat <- decode.field("repeat", decode.bool)
        decode.success(#(key, repeat))
      }),
    )
    use <- guard(repeat, Ok(Nil))
    dispatch(Keydown(key)) |> Ok
  })
}
