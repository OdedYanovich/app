import { pixel_dimensions, pixel_rows_columns } from "./root.mjs";
let ctx;

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
        function main() {
            requestAnimationFrame(main);
            loop(performance.now());
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
export function draw(x, y, pixel_id) {
    ctx.drawImage(
        img,
        pixel_id % pixel_rows_columns,
        Math.floor(pixel_id / pixel_rows_columns),
        1,
        1,
        x,
        y,
        pixel_dimensions,
        pixel_dimensions,
        // 50,50
    );
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}
