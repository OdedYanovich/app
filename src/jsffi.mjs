let ctx;
let time;
// canvas stuff
// const img = new Image(8, 8);
// img.src = "/assets/foo.png";
// const imgCanvas = new OffscreenCanvas(8, 8);
// const imgCtx = imgCanvas.getContext("2d");
// imgCtx.drawImage(img, 0, 0);
// const imgData = imgCtx.getImageData(0, 0, 8, 8);

export function init(loop, resize, keydownEvent) {
    requestAnimationFrame(() => {
        ctx = document.getElementById("canvas").getContext("2d");
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
    ctx.rect(0, 0, innerWidth, innerHeight);
    ctx.fill();
    ctx.closePath();
    ctx.fillStyle = "blue";
}
export function draw(particle) {
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
