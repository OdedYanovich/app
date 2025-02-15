let canvas;
let ctx;
let time;

export function init(loop, resize, keydownEvent) {
    requestAnimationFrame(() => {
        canvas = document.getElementById("canvas");
        ctx = canvas.getContext("2d");

        addEventListener(
            "resize",
            () => {
                resize(innerWidth, innerHeight);
            },
        );
        addEventListener("keydown", keydownEvent);
        time = performance.now();
        function main() {
            requestAnimationFrame(main);
            loop(performance.now() - time);
            time = performance.now();
        }
        main();
    });
}
export function sandCanvasSize() {
    return [innerWidth, innerHeight];
}

export function startDrawing() {
    ctx.beginPath();
    ctx.fillStyle = "rgba(0,0,0,0.02)";
    ctx.rect(0, 0, window.innerWidth, window.innerHeight);
    ctx.fill();
    ctx.closePath();
}
export function draw(particle) {
    ctx.fillStyle = "blue";
    ctx.beginPath();
    ctx.arc(particle[0], particle[1], 36, 0., Math.PI * 2.);
    ctx.fill();
    ctx.closePath();
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}

// import { bar } from "./app.mjs"; // Interop example
