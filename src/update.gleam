import array.{new_array}
import draw.{draw_frame}
import gleam/dict
import gleam/dynamic/decode
import gleam/option.{None, Some}
import gleam/result.{try}
import gleam/string
import prng/seed
import responses/responses.{entering_hub}
import root.{
  type Model, type Msg, Dmg, Draw, EndDmg, Hub, Image, Keydown, Model, Resize,
  StartDmg, add_effect, effectless,
}

pub fn update(model: Model, msg: Msg) {
  case msg {
    Draw(program_duration) ->
      draw_frame(model, program_duration) |> root.effectless

    Keydown(key) -> {
      case model.responses |> dict.get(key |> string.lowercase) {
        Ok(response) -> response(Model(..model, latest_key_press: key))
        Error(_) -> model |> effectless
      }
    }
    Dmg -> Model(..model, hp: model.hp -. 0.02) |> effectless
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
    hp_lose_interval_id: None,
    unlocked_levels: 3,
    selected_level: 2,
    timer: 0.0,
    program_duration: 0.0,
    viewport_width: get_viewport_size().0,
    viewport_height: get_viewport_size().1,
    image: Image(
      stationary_pixels: new_array(8 * 8),
      moving_pixels: [],
      columns_fullness: new_array(8),
      full_columns: 0,
      rows: 8,
      columns: 8,
      spawn_offset: #(400.0, 800.0),
      stopping_offset: #(400.0, 400.0),
    ),
    seed: seed.random(),
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

@external(javascript, "./jsffi.mjs", "init")
fn init_js(
  loop: fn(Float) -> Nil,
  resize: fn(Int, Int) -> Nil,
  keydown_event: fn(decode.Dynamic) -> any,
) -> Nil

@external(javascript, "./jsffi.mjs", "sandCanvasSize")
fn get_viewport_size() -> #(Int, Int)

@external(javascript, "./jsffi.mjs", "endHpLose")
fn end_hp_lose(id: Int) -> Nil

@external(javascript, "./jsffi.mjs", "startHpLose")
fn start_hp_lose(handler: fn() -> any) -> Int
