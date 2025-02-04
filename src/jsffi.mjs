export function t(c) {
    const canvas = document.querySelector("canvas");
    const ctx = canvas.getContext("2d");

    ctx.beginPath();
    ctx.fillStyle = "white";
    ctx.arc(20, 20, 1, 0., Math.PI * 2., true);
    ctx.closePath();
    ctx.fill();
}
export function keyboardEvents(handler) {
    addEventListener("keydown", handler);
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}
// ///En example of interop
// import { bar } from "./app.mjs";
// pub fn bar() {
//   "bar"
// }
