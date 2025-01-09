import { bar } from "./app.mjs";
let currentKey = "f";
export function initialize(combo_tracker, first_mod) {
    window.addEventListener("keydown", async (event) => {
        if (event.repeat) return;
        currentKey = event.key.toLowerCase();
        console.log(bar());
    });
}
export function getCurrentKey() {
    return currentKey;
}
