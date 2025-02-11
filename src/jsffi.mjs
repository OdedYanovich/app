let canvas;
let ctx;
let start;
export function init(drawParticles, keydownEvent) {
    requestAnimationFrame(() => {
        canvas = document.getElementById("canvas");
        ctx = canvas.getContext("2d");
        sizeCanvas();
        addEventListener("resize", sizeCanvas);
        addEventListener("keydown", keydownEvent);
        function main(timeStamp) {
            requestAnimationFrame(main);
            // Problematic if statement
            if (start === undefined) {
                start = timeStamp;
            }
            console.log(timeStamp - start)
            drawParticles(timeStamp - start);
        }
        main();
    });
}
export function startDrawing() {
    ctx.beginPath();
    ctx.fillStyle = "rgba(0,0,0,0.02)";
    ctx.rect(0, 0, innerWidth, innerHeight);
    ctx.fill();
    ctx.closePath();
}
export function draw(particle) {
    ctx.fillStyle = "blue";
    ctx.beginPath();
    ctx.arc(particle[0], particle[1], 5, 0., Math.PI * 2.);
    ctx.fill();
    ctx.closePath();
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}
let w, h, scale;
function sizeCanvas() {
    w = innerWidth;
    h = innerHeight;
    scale = devicePixelRatio;
    canvas.width = w * scale;
    canvas.height = h * scale;
    ctx.scale(scale, scale);
    // ctx.canvas.width = innerWidth;
    // ctx.canvas.height = innerHeight;
    // canvas.width = innerWidth;
    // canvas.height = innerHeight;
    // ctx.scale(innerWidth, innerHeight);
}

// viewport

// Interop example
// import { bar } from "./app.mjs";
