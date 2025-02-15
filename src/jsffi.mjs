let canvas;
let ctx;
// let elementsWrapper;
let time;

export function init(loop, keydownEvent) {
    requestAnimationFrame(() => {
        // elementsWrapper = document.getElementById("wrapper");
        canvas = document.getElementById("canvas");
        ctx = canvas.getContext("2d");

        sizeCanvas();
        addEventListener("resize", sizeCanvas);
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

function sizeCanvas() {
    // const pixelRatio = window.devicePixelRatio;

    // canvas.width = pixelRatio * innerWidth;
    // canvas.height = pixelRatio * innerHeight;
    // ctx.scale(pixelRatio, pixelRatio);
    canvas.width = 700;
    canvas.height = 700;
    // canvas.tyle.width = "700px";
    // canvas.style.height = "700px";
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
    ctx.arc(particle[0], particle[1], 6, 0., Math.PI * 2.);
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
