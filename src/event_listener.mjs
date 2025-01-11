import { bar } from "./app.mjs";
let currentKey = "t";
// export function initialize(combo_tracker, first_mod) {
//     window.addEventListener("keydown", async (event) => {
//         if (event.repeat) return;
//         currentKey = event.key.toLowerCase();
//         console.log(bar(), currentKey, dispatchEvent(new Event("r")));
//     });
// }
export function initialize(handler) {
    window.addEventListener("keydown", handler);
}
export function getCurrentKey() {
    return currentKey;
}
