let ctx;
let time;

const img = new Image(8, 8);
img.src = "/assets/foo.png";
export function init(loop, resize, keydownEvent) {
    requestAnimationFrame(() => {
        ctx = document.getElementById("canvas").getContext("2d");
        ctx.imageSmoothingEnabled = false;
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
    ctx.fillStyle = "rgba(0,0,0,255)";
    ctx.rect(0, 0, innerWidth, innerHeight);
    ctx.fill();
}
export function draw(particle) {
    ctx.drawImage(
        img,
        particle.count % 8,
        Math.floor(particle.count / 8),
        1,
        1,
        particle.pos_x,
        particle.pos_y,
        50,
        50,
    );
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}

// import { bar } from "./app.mjs"; // Interop example
