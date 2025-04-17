// @external(javascript, "./js/sound.mjs", "play")
// pub fn play(volume: Float) -> Nil
//
@external(javascript, "./js/sound.mjs", "pause")
pub fn pause() -> Nil

@external(javascript, "./js/sound.mjs", "play")
pub fn play(id: Int) -> Nil

@external(javascript, "./js/sound.mjs", "changeVolume")
pub fn change_volume(volume: Float) -> Nil

@external(javascript, "./js/sound.mjs", "initAudio")
pub fn init_audio(volume: Float) -> Nil
