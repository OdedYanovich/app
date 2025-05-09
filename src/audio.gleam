import ffi/main.{get_time}
import ffi/sound
import gleam/int
import root.{
  type Model, type RangedVal, Hub, HubBody, Model, Range, update_ranged_int,
}

pub fn change_volume(model: Model, change) {
  let volume = case model.volume |> pass_the_limit {
    True ->
      Range(
        ..model.volume,
        val: model.volume.val + change - { model.volume.max + 1 },
      )

    False -> model.volume |> update_ranged_int(change)
  }
  sound.change_volume(
    { volume.val |> int.to_float } /. { volume.max |> int.to_float },
  )
  Model(..model, mod: HubBody(get_time() +. 500.0) |> Hub, volume:)
}

pub fn mute_toggle(model: Model) {
  Model(..model, volume: case model.volume |> pass_the_limit {
    True ->
      Range(..model.volume, val: model.volume.val - { model.volume.max + 1 })
    False -> {
      sound.pause()
      Range(..model.volume, val: model.volume.val + model.volume.max + 1)
    }
  })
}

pub fn get_val(range: RangedVal(Int)) {
  case range |> pass_the_limit {
    True -> range.val - { range.max + 1 }
    False -> range.val
  }
}

pub fn pass_the_limit(range: RangedVal(Int)) {
  range.val > range.max
}
