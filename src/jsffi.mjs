export function t(c) {
    const canvas = document.querySelector("canvas");
    // const ctx = canvas.getContext("2d");
    console.log(c)

    // ctx.font = "50px Arial";
    // ctx.fillText("Hello World", 10, 80);
    return c
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
