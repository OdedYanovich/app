const audioContext = new AudioContext();
const audioElements = [document.getElementById("set1-1"), document.getElementById("set1-2"), document.getElementById("set1-3"), document.getElementById("set1-4")]
const tracks = audioElements.map((source) => audioContext.createMediaElementSource(source))
const gainNode = audioContext.createGain();
tracks.map((track) => track.connect(gainNode).connect(audioContext.destination))

export function play(id) {
	audioContext.resume();
	audioElements[0].play();
}
export function changeVolume(volume) {
	gainNode.gain.value = volume
}
export function pause() {
	audioElements[1].pause()
}
export function initAudio(volume) {
	audioContext.resume();
	gainNode.gain.value = volume
}
