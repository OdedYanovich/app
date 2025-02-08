let canvas;
let ctx;
let particles;
setTimeout(() => {
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    draw();
}, 40);

// window.addEventListener("resize", () => {
//     var box = canvas.getBoundingClientRect();
//     canvas.width = box.width;
//     canvas.height = box.height;
// });

function draw() {
    ctx.beginPath();
    ctx.fillStyle = "blue";
    for (const particle of particles) {
        ctx.arc(particle[0], particle[1], 30, 0., Math.PI * 2.);
        ctx.fill();
    }
    ctx.closePath();
}
export function setParticles() {
    particles = [[40., 20.], [80., 80.], [100., 100.]];
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
