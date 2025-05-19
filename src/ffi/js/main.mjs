let modeLink
export function initGameLoop(model_link, callback) {
	modeLink = model_link
	// function main() {
	// 	requestAnimationFrame(main);
	// 	callback();
	// }
	// main();
}
export function initKeydownEvent(callback) {
	addEventListener("keydown", callback);
}
export function timer(callback, delay) {
	setTimeout(() => { callback(modeLink) }, delay)
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
	return parseInt(localStorage.getItem(name))
}
export function log2(val) {
	return Math.log2(val)
}
export function getTime() { return performance.now() }
