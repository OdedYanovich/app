// let ctx;
// ctx = document.getElementById("canvas").getContext("2d");
// ctx.imageSmoothingEnabled = false;
// ctx.fillStyle = "rgba(0,0,0,255)";
export function initGameLoop(callback) {
    function main() {
        requestAnimationFrame(main);
        callback(performance.now());
    }
    main();
}
export function initKeydownEvent(callback) {
    addEventListener("keydown", callback);
}
export function initResizeEvent(callback) {
    addEventListener(
        "resize",
        () => {
            callback(innerWidth, innerHeight);
        },
    );
}

export function sandCanvasSize() {
    return [innerWidth, innerHeight];
}
export function startDrawing() {
    ctx.rect(0, 0, innerWidth, innerHeight);
    ctx.fill();
}