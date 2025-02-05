export function t(c) {
    const canvas = document.getElementById("canvas");

    const ctx = canvas.getContext("2d");

    ctx.beginPath();
    ctx.fillStyle = "white";
    ctx.arc(5, 6, 1, 0., Math.PI * 2.);
    ctx.fill();
    ctx.closePath();
    // ctx.stroke();
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
