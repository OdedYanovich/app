// import gleam/list
// import root.{
//   type Response, Credit, Fight, Hub, Level, Model, Phase, all_command_keys,
// }

// pub fn morph(model, mod, imports) {
//   let Imports(level_buttons, entering_hub, entering_fight, entering_credit) =
//     imports
//   case mod {
//     Hub -> todo
//     Fight ->
//       Model(
//         ..model,
//         mod:,
//         level: Level(
//           buttons: all_command_keys
//             |> level_buttons(model.selected_level),
//           initial_presses: 20,
//           phase: Phase(
//             buttons: all_command_keys
//               |> level_buttons(model.selected_level),
//             press_per_minute: 2,
//             press_per_mistake: 8,
//             time: 1000.0,
//           ),
//           transition_rules: fn(_state) {
//             Phase(
//               buttons: all_command_keys
//                 |> level_buttons(model.selected_level),
//               press_per_minute: 2,
//               press_per_mistake: 8,
//               time: 1000.0,
//             )
//           },
//           press_counter: 0,
//         ),
//         required_combo: all_command_keys
//           |> level_buttons(model.selected_level)
//           |> list.shuffle,
//         responses: entering_fight(entering_hub)
//           |> dict.from_list,
//       )
//     Credit -> Model(..model, mod:, responses: entering_credit(entering_hub))
//   }
// }

// pub type Imports {
//   Imports(
//     level_buttons: fn(List(String), Int) -> List(String),
//     entering_hub: fn() -> List(#(String, Response)),
//     entering_fight: fn(
//       fn(List(#(String, Response))) -> List(#(String, Response)),
//     ) ->
//       List(#(String, Response)),
//     entering_credit: fn(
//       fn(List(#(String, Response))) -> List(#(String, Response)),
//     ) ->
//       List(#(String, Response)),
//   )
// }
