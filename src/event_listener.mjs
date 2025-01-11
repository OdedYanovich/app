let currentKey = "t";
export function initialize(handler) {
    window.addEventListener("keydown", handler);
}

// ///En example of interop
// import { bar } from "./app.mjs";
// pub fn bar() {
//   "bar"
// }