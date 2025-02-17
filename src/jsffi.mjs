let ctx;
let time;

// let imgCtx;
// const img = new Image(8,8);
// img.src = "../assets/foo.jpg";
// img.crossOrigin = "anonymous";
// const imgData = imgCtx.getImageData(0, 0, 80, 80);

let img;
export function init(loop, resize, keydownEvent) {
    requestAnimationFrame(() => {
        ctx = document.getElementById("canvas").getContext("2d");
        // imgCtx = document.getElementById("imgCanvas").getContext("2d");
        // imgCtx.drawImage(img, 0, 0);
        // img = document.getElementById("img").files;
        // console.log(img)
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
    // ctx.beginPath();
    // ctx.fillStyle = "rgba(0,0,0,0.02)";
    // ctx.rect(0, 0, innerWidth, innerHeight);
    // ctx.fill();
    // ctx.closePath();

    // ctx.putImageData(imgData, 80, 80);
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
