const audioElement = document.getElementById("metronome1");
let firstTime = true
let gainNode
let audioContext
let track
export function play(volume) {
	if (firstTime) {
		firstTime = false
		audioContext = new AudioContext()
		track = audioContext.createMediaElementSource(audioElement);
		gainNode = audioContext.createGain();
	}
	gainNode.gain.value = volume
	track.connect(gainNode).connect(audioContext.destination);
	audioElement.play();
}
export function pause() {
	audioElement.pause();
}
const audioElements = [document.getElementById("clap"), document.getElementById("cymbal3")]
export function simplePlay(id) {
	audioElements[id].play()
}
export function changeVolume(volume) {
	audioElements.forEach((sound) => sound.volume = volume
	)
}
