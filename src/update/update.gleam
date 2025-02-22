import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{try}
import gleam/string
import root.{
  type Model, type Msg, Dmg, Draw, EndDmg, Hub, Keydown, MPixel, Model, Pixel,
  Resize, StartDmg, add_effect, effectless,
}
import update/responses.{entering_hub}

@external(javascript, "../jsffi.mjs", "endHpLose")
fn end_hp_lose(id: Int) -> Nil

@external(javascript, "../jsffi.mjs", "startHpLose")
fn start_hp_lose(handler: fn() -> any) -> Int

pub fn update(model: Model, msg: Msg) {
  case msg {
    Draw(program_duration) -> {
      let time_elapsed = program_duration -. model.program_duration
      let speed = 0.1 *. time_elapsed
      let #(stationary_pixels, moving_pixels) = case
        list.first(model.moving_pixels)
      {
        Ok(last_pixel) if last_pixel.time_since_creation >. 3000.0 -> {
          #(
            model.stationary_pixels
              |> list.append([Pixel(last_pixel.pos, last_pixel.pixel_id)]),
            model.moving_pixels |> list.drop(1),
          )
        }
        _ -> #(model.stationary_pixels, model.moving_pixels)
      }
      start_drawing()
      model.stationary_pixels
      |> list.append(
        model.moving_pixels
        |> list.map(fn(pixel) { Pixel(pixel.pos, pixel.pixel_id) }),
      )
      |> list.map(fn(pixel) { draw(pixel.pos.0, pixel.pos.1, pixel.pixel_id) })
      Model(
        ..model,
        stationary_pixels:,
        moving_pixels: moving_pixels
          |> list.map(fn(pixel) {
            MPixel(
              #(pixel.pos.0, pixel.pos.1 -. speed),
              pixel.pixel_id,
              pixel.time_since_creation +. time_elapsed,
            )
          }),
        timer: model.timer -. time_elapsed,
        program_duration:,
      )
      |> effectless
    }
    Keydown(key) -> {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> response(Model(..model, latest_key_press: key))
        Error(_) -> model |> effectless
      }
    }
    Dmg -> Model(..model, hp: model.hp -. 0.02) |> effectless
    StartDmg(dispatch) ->
      Model(..model, interval_id: Some(start_hp_lose(fn() { dispatch(Dmg) })))
      |> effectless
    EndDmg -> {
      end_hp_lose(model.interval_id |> option.unwrap(0))
      Model(..model, interval_id: None) |> effectless
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
fn draw(x: Float, y: Float, pxiel_id: Int) -> Nil

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
    stationary_pixels: [],
    moving_pixels: [],
    timer: 0.0,
    program_duration: 0.0,
    viewport_x: get_viewport_size().0,
    viewport_y: get_viewport_size().1,
    drawn_pixel_count: 0,
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
    use <- guard(repeat, Ok(Nil))
    dispatch(Keydown(key)) |> Ok
  })
}
