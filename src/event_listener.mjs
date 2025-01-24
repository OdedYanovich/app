let currentKey = "t";
export function initialize(key_down_event_handler// key_up_event_handler
) {
    window.addEventListener("keydown", key_down_event_handler);
    // window.addEventListener("keyup", key_up_event_handler);
}

// ///En example of interop
// import { bar } from "./app.mjs";
// pub fn bar() {
//   "bar"
// }
