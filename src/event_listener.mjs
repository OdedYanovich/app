export function keyboardEvents(handler) {
    addEventListener("keydown", handler);
}
export function hpLose(handler) {
    return setInterval(handler, 1);
}
// ///En example of interop
// import { bar } from "./app.mjs";
// pub fn bar() {
//   "bar"
// }
