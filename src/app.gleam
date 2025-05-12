import audio.{get_val}
import ffi/main.{init_game_loop, init_keydown_event, set_storage}
import ffi/sound
import fight
import gleam/bool.{guard}
import gleam/dict
import gleam/dynamic/decode
import gleam/result.{try}
import gleam/string
import initialization.{init}
import lustre.{dispatch}
import prng/random
import root.{
  type Identification, type Model, After, Before, Credit, CreditId, Fight,
  FightBody, FightId, Frame, Hub, HubBody, HubId, IntroductoryFight,
  IntroductoryFightId, Keydown, Model, None, NorthEast, NorthWest, SouthEast,
  SouthWest, StableMod, mod_transition_time, stored_level_id, stored_volume_id,
}
import sequence_provider
import view/view.{view}

pub fn main() {
  let assert Ok(update_the_model) =
    fn(model: Model, msg) {
      case msg {
        Frame -> {
          let current_time = main.get_time()
          case model.mod_transition {
            Before(timer, id) if timer <. current_time -> morphism(model, id)
            After(timer) if timer <. current_time ->
              Model(..model, mod_transition: StableMod)
            _ -> model
          }
          |> fn(model) {
            case model.mod {
              Hub(hub) if hub.volume_timer <. current_time -> {
                set_storage(stored_volume_id, model.volume |> get_val)
                model
              }
              _ -> model
            }
          }
        }
        Keydown(latest_key_press) -> {
          use <- guard(model.mod_transition != StableMod, model)
          {
            use group <- result.try(
              model.key_groups
              |> dict.get(#(
                model.mod |> id,
                latest_key_press |> string.lowercase,
              )),
            )
            use response <- result.try(
              model.grouped_responses
              |> dict.get(#(model.mod |> id, group)),
            )
            case model.volume |> audio.pass_the_limit {
              False -> sound.play(0)
              True -> Nil
            }
            response(model) |> Ok
          }
          |> result.unwrap(model)
        }
      }
    }
    |> lustre.simple(init, _, view)
    |> lustre.start("#app", Nil)
  init_game_loop(fn() { update_the_model(dispatch(Frame)) })
  use event <- init_keydown_event
  use #(key, repeat) <- try(
    decode.run(event, {
      use key <- decode.field("key", decode.string)
      use repeat <- decode.field("repeat", decode.bool)
      decode.success(#(key, repeat))
    }),
  )
  use <- guard(repeat, Ok(Nil))
  update_the_model(dispatch(key |> Keydown)) |> Ok
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
  let after = fn(mod, seed) {
    Model(
      ..model,
      mod:,
      seed:,
      mod_transition: After(main.get_time() +. mod_transition_time),
    )
  }
  case mod {
    HubId ->
      case id(model.mod) {
        IntroductoryFightId ->
          Model(
            ..model,
            mod: 0.0 |> HubBody |> Hub,
            mod_transition: After(main.get_time() +. mod_transition_time),
            grouped_responses: model.grouped_responses
              |> dict.drop([
                #(IntroductoryFightId, NorthEast),
                #(IntroductoryFightId, SouthEast),
                #(IntroductoryFightId, NorthWest),
                #(IntroductoryFightId, SouthWest),
              ]),
          )
        _ -> 0.0 |> HubBody |> Hub |> after(model.seed)
      }
    FightId -> {
      let #(direction_randomizer, seed) =
        random.choose(True, False) |> random.step(model.seed)
      let selected_level = model.selected_level |> get_val
      set_storage(stored_level_id, selected_level)
      let #(sequence_provider, _sequence_provider_length) =
        selected_level |> sequence_provider.get
      FightBody(
        sequence_provider:,
        last_action_group: None,
        progress: fight.init_progress(selected_level),
        direction_randomizer:,
      )
      |> Fight
      |> after(seed)
    }
    CreditId -> after(Credit, model.seed)
    IntroductoryFightId -> panic
  }
}
