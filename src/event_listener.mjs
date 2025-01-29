export function keyboardEvents(handler) {
    addEventListener("keydown", handler);
}
let id;
export function startHpLose(handler) {
    id = setInterval(handler, 1);
}
export function endHpLose() {
    clearInterval(id);
}
// ///En example of interop
// import { bar } from "./app.mjs";
// pub fn bar() {
//   "bar"
// }
