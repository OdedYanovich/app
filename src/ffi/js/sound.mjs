//document.getElementById("metronome1");
const audioContext = new AudioContext();
const audioElements = [document.getElementById("set1-1"), document.getElementById("set1-2"), document.getElementById("set1-3"), document.getElementById("set1-4")]
//const track0 = audioContext.createMediaElementSource(audioElements[0]);
//const track1 = audioContext.createMediaElementSource(audioElements[1]);
const tracks = audioElements.map((source) => audioContext.createMediaElementSource(source))
const gainNode = audioContext.createGain();
//track0.connect(gainNode).connect(audioContext.destination);
//track1.connect(gainNode).connect(audioContext.destination);
tracks.map((track) => track.connect(gainNode).connect(audioContext.destination))

export function play(id) {
	//if (audioContext.state === "suspended") {
	audioContext.resume();
	//}
	audioElements[id].play();
}
export function changeVolume(volume) {
	gainNode.gain.value = volume
	//audioElements.forEach((sound) => sound.volume = volume
	//)
}
export function pause() {
	audioElements.forEach((sound) =>
		sound.pause()
	)
}
export function initAudio(volume) {
	audioContext.resume();
	gainNode.gain.value = volume
}
