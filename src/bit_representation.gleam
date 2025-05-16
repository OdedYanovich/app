import gleam/int
import root.{type BitRepresentation, type Mask, BitRepresentation, Mask}

pub fn next(mask: Mask) {
  mask.val |> int.bitwise_shift_left(1) |> Mask
}

pub fn previuos(mask: Mask) {
  mask.val |> int.bitwise_shift_left(1) |> Mask
}

pub fn get(representation: BitRepresentation, mask: Mask) {
  representation.val |> int.bitwise_and(mask.val)
}

pub fn set(representation: BitRepresentation, mask: Mask) {
  representation.val |> int.bitwise_or(mask.val) |> BitRepresentation
}
// /// Callback for every positive bit
// pub fn fold(
//   state: t,
//   representation: BitRepresentation,
//   callback: fn(t, Int) -> t,
// ) {
//   let mask = 1
// }
