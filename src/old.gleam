pub type Image {
  Image(
    stationary_pixels: OldArray(OldArray(Bool)),
    moving_pixels: OldArray(OldArray(MovingPixel)),
    available_column_indices: OldArray(Int),
    columns_fullness: OldArray(Int),
    rows: Int,
    columns: Int,
    spawn_offset: Position,
    stopping_offset: Position,
  )
}

pub type MovingPixel {
  Pixel(existence_time: Float, position: Position, trajectory: Position)
}

pub type TransitionFromFight {
  DoNothing
  ToHub
}

pub type OldArray(t)

pub type Position =
  #(Float, Float)

pub const pixel_dimensions = 50
