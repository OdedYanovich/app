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
  type Identification, type Model, Attack, Credit, CreditId, Fight, FightBody,
  FightId, Hub, HubId, Ignored, IntroductoryFight, IntroductoryFightId, Keydown,
  Model, NorthEast, NorthWest, SouthEast, SouthWest, ToMod, TransitionAnimation,
  stored_level_id, stored_volume_id,
}
import sequence_provider
import view/view.{view}

pub fn main() {
  let assert Ok(model_link) =
    fn(model: Model, msg) {
      case msg {
        Keydown(latest_key_press) -> {
          use <- guard(model.mod_transition != ToMod, model)
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
        TransitionAnimation(mod) -> morphism(model, mod)
      }
    }
    |> lustre.simple(init, _, view)
    |> lustre.start("#app", Nil)
  init_game_loop(model_link)
  use event <- init_keydown_event
  use #(key, repeat) <- try(
    decode.run(event, {
      use key <- decode.field("key", decode.string)
      use repeat <- decode.field("repeat", decode.bool)
      decode.success(#(key, repeat))
    }),
  )
  use <- guard(repeat, Ok(Nil))
  model_link |> lustre.send(dispatch(key |> Keydown)) |> Ok
}

fn id(mod) {
  case mod {
    Hub -> HubId
    Fight(_) -> FightId
    Credit -> CreditId
    IntroductoryFight(_) -> IntroductoryFightId
  }
}

fn morphism(model: Model, mod: Identification) -> Model {
  let after = fn(mod, seed) {
    Model(..model, mod:, seed:, mod_transition: ToMod)
  }
  case mod {
    HubId ->
      case id(model.mod) {
        IntroductoryFightId ->
          Model(
            ..model,
            mod:  Hub,
            mod_transition: ToMod,
            grouped_responses: model.grouped_responses
              |> dict.drop([
                #(IntroductoryFightId, Attack(NorthEast)),
                #(IntroductoryFightId, Attack(SouthEast)),
                #(IntroductoryFightId, Attack(NorthWest)),
                #(IntroductoryFightId, Attack(SouthWest)),
              ]),
          )
        _ -> Hub |> after(model.seed)
      }
    FightId -> {
      set_storage(stored_volume_id, model.volume |> get_val)
      let #(direction_randomizer, seed) =
        random.choose(True, False) |> random.step(model.seed)
      let selected_level = model.selected_level |> get_val
      set_storage(stored_level_id, selected_level)
      let #(sequence_provider, clue) = selected_level |> sequence_provider.get
      FightBody(
        sequence_provider:,
        last_action_group: Attack(Ignored),
        progress: fight.init_progress(selected_level),
        direction_randomizer:,
        clue:,
      )
      |> Fight
      |> after(seed)
    }
    CreditId -> after(Credit, model.seed)
    IntroductoryFightId -> panic
  }
}
