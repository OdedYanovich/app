// let ctx;

export function init(loop, resize, keydownEvent) {
    requestAnimationFrame(() => {
        // ctx = document.getElementById("canvas").getContext("2d");
        // ctx.imageSmoothingEnabled = false;
        // ctx.fillStyle = "rgba(0,0,0,255)";
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
export function startHpLose(handler) {
    return setInterval(handler, 1);
}
export function endHpLose(id) {
    clearInterval(id);
}
