import { pixel_dimensions } from "./root.mjs";
let ctx;

const img = new Image(8, 8);
img.src = "/assets/foo.png";
export function init(loop, resize, keydownEvent) {
    requestAnimationFrame(() => {
        ctx = document.getElementById("canvas").getContext("2d");
        ctx.imageSmoothingEnabled = false;
        ctx.fillStyle = "rgba(0,0,0,255)";
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
    ctx.rect(0, 0, innerWidth, innerHeight);
    ctx.fill();
}
export function draw(x, y, row, column) {
    ctx.drawImage(
        img,
        row,
        column,
        1,
        1,
        x,
        y,
        pixel_dimensions,
        pixel_dimensions,
    );
}
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}
// export function random(max) {}

export function newArray(size) {
    Array(size);
}
export function new2dArray(rows, columns) {
    return Array(rows).fill().map(() => Array(columns).fill(false));
}
export function get(array, index) {
    return array[index];
}
export function addOne(array, index) {
    array[index] += 1;
    return array;
}

export function pixelOn(index, array) {
    array[index] = true;
    return array;
}
export function iter(image, fun) {
    image.forEach((column, column_index) => {
        column.forEach((pixel, row_index) => {
            fun(pixel, row_index, column_index);
        });
    });
}
export function map(array, fun) {
    array.map(fun);
}
