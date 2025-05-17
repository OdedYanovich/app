import ffi/main
import funtil
import gleam/bool
import gleam/int
import gleam/list
import root.{type SequenceProvider, SequenceProvider}

pub fn get(id) {
  let #(repeation_map, msb) =
    {
      use make_constant, mask, excess <- funtil.fix2
      let next_mask = mask |> int.bitwise_shift_left(1)
      let next_excess = excess + next_mask
      use <- bool.guard(next_excess > id, #(id - excess, mask))
      make_constant(next_mask, next_excess)
    }(1, 0)
  let sequence_provider =
    SequenceProvider(
      repeation_map:,
      msb:,
      current_index: 1,
      loop_map: 0,
      repeation_accrued: False,
    )
  #(
    sequence_provider,
    {
      let len = id
      use fold, current_provider, elements, i <- funtil.fix3
      use <- bool.guard(i == len, elements)
      fold(
        current_provider |> next_element,
        elements |> list.append([current_provider |> get_element]),
        i + 1,
      )
    }(sequence_provider |> next_element, [sequence_provider |> get_element], 0),
  )
}

pub fn next_element(provider: SequenceProvider) {
  let index_is_maxed = provider.current_index >= provider.msb
  let repeation_required =
    provider.repeation_map
    |> int.bitwise_and(provider.current_index)
    != 0
    && !provider.repeation_accrued
  let sequence_provider = case repeation_required, index_is_maxed {
    True, False -> provider
    False, True -> {
      let #(loop_map, current_index) =
        {
          use backwards, index_map, loop_index <- funtil.fix2
          use <- bool.guard(index_map |> int.bitwise_and(loop_index) == 0, #(
            index_map |> int.bitwise_or(loop_index),
            loop_index,
          ))
          use <- bool.guard(loop_index == 1, #(0, 1))
          backwards(
            index_map - loop_index,
            loop_index |> int.bitwise_shift_right(1),
          )
        }(provider.loop_map, provider.msb)
      SequenceProvider(..provider, loop_map:, current_index:)
    }
    False, False | True, True ->
      SequenceProvider(
        ..provider,
        current_index: provider.current_index |> int.bitwise_shift_left(1),
      )
  }
  SequenceProvider(..sequence_provider, repeation_accrued: repeation_required)
}

pub fn get_element(provider: SequenceProvider) {
  // Use a table 
  main.log2(provider.current_index) % 2 != 0
}
