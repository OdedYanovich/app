let canvas;
let ctx;
let start
export function init(drawParticles, keydownEvent) {
    requestAnimationFrame(() => {
        function main(timeStamp) {
            requestAnimationFrame(main);
            if (start === undefined) {
                start = timeStamp;
            }
            const elapsed = timeStamp - start;
            drawParticles();
        }
        canvas = document.getElementById("canvas");
        ctx = canvas.getContext("2d");
        ctx.canvas.width = window.innerWidth;
        ctx.canvas.height = window.innerHeight;
        main();
    });
    addEventListener("keydown", keydownEvent);
}
export function draw(particles) {
    ctx.beginPath();
    ctx.fillStyle = "black";
    ctx.rect(0, 0, innerWidth, innerHeight);
    ctx.fill();
    ctx.closePath();
    ctx.fillStyle = "blue";
    for (const particle of particles) {
        ctx.beginPath();
        ctx.arc(particle[0], particle[1], 45, 0., Math.PI * 2.);
        ctx.fill();
        ctx.closePath();
    }
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}
function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  
  // Additional logic to redraw graphics based on new size
}
window.addEventListener('resize', resizeCanvas);

// viewport

// Interop example
// import { bar } from "./app.mjs";
