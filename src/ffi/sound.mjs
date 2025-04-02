const audioElement = document.getElementById("metronome1");
let firstTime = true
export function play(volume) {
	if (firstTime) {
		firstTime = false
		const audioContext = new AudioContext()
		const track = audioContext.createMediaElementSource(audioElement);
		const gainNode = audioContext.createGain();
		gainNode.gain.value = volume
		track.connect(gainNode).connect(audioContext.destination);
	}
	audioElement.play();
}
export function pause() {
	audioElement.pause();
}

