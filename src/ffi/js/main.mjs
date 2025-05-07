export function initGameLoop(callback) {
	function main() {
		requestAnimationFrame(main);
		callback(performance.now());
	}
	main();
}
export function initKeydownEvent(callback) {
	addEventListener("keydown", callback);
}
export function initResizeEvent(callback) {
	addEventListener(
		"resize",
		() => {
			callback(innerWidth, innerHeight);
		},
	);
}

export function sandCanvasSize() {
	return [innerWidth, innerHeight];
}
export function startDrawing() {
	ctx.rect(0, 0, innerWidth, innerHeight);
	ctx.fill();
}
export function setStorage(name, val) {
	localStorage.setItem(name, val)
}
export function getStorage(name) {
	let val = parseInt(localStorage.getItem(name))
	if (val) {
		return val
	} else {
		return 9999
	}

}
export function log2(val) {
	return Math.log2(val)
}
