const audioContext = new AudioContext();
const audioElement = getElementById("metronome1");
const track = audioContext.createMediaElementSource(audioElement);

