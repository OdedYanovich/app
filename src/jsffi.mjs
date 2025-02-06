let canvas;
let ctx;
setTimeout(() => {
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    t();
}, 40);

export function t() {
    ctx.beginPath();
    ctx.fillStyle = "blue";
    ctx.arc(40, 40, 30, 0., Math.PI * 2.);
    ctx.fill();
    ctx.closePath();
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
