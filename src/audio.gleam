import ffi/gleam/sound
import gleam/int
import root.{
  type Model, type RangedInt, Hub, HubBody, Model, Range, update_range,
}

pub fn change_volume(model: Model, change) {
  Model(
    ..model,
    mod: HubBody(model.program_duration +. 500.0) |> Hub,
    volume: case model.volume |> pass_the_limit {
      True -> {
        let val = model.volume.val + change - { model.volume.max + 1 }
        sound.play(
          { val |> int.to_float } /. { model.volume.max |> int.to_float },
        )
        Range(..model.volume, val:)
      }
      False -> {
        let volume = model.volume |> update_range(change)
        sound.play(
          { volume.val |> int.to_float } /. { model.volume.max |> int.to_float },
        )
        volume
      }
    },
  )
}

pub fn mute_toggle(model: Model) {
  Model(..model, volume: {
    case model.volume |> pass_the_limit {
      True -> {
        let val = model.volume.val - { model.volume.max + 1 }
        sound.play(
          { val |> int.to_float } /. { model.volume.max |> int.to_float },
        )
        Range(..model.volume, val:)
      }
      False -> {
        sound.pause()
        Range(..model.volume, val: model.volume.val + model.volume.max + 1)
      }
    }
  })
}

pub fn get_val(range: RangedInt) {
  case range |> pass_the_limit {
    True -> range.val - { range.max + 1 }
    False -> range.val
  }
}

pub fn pass_the_limit(range: RangedInt) {
  range.val > range.max
}
