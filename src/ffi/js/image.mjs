import { pixel_dimensions } from "./root.mjs";
let stationaryPixels,
    movingPixels,
    columnsFullness;
export function createNew(rows, columns) {
    stationaryPixels = Array.from(
        { length: columns },
        () => Array.from({ length: rows }, () => false),
    );
    movingPixels = Array.from(
        { length: columns },
        () => Array.from({ length: 0 }),
    );
    columnsFullness = Array.from({ length: columns }, () => 0);
}
export function addMovingPixel(columnIndex, pixel) {
    movingPixels[columnIndex].push(pixel);
    console.log(movingPixels);
}
export function drawAndUpdateImage(stoppingTime) {
    movingPixels.map((column, columnIndex) => {
        if (column[0].existence_time >= stoppingTime) {
            movingPixels.shift();
            stationaryPixels[columnIndex];
        }
    });
}
const img = new Image(8, 8);
img.src = "/assets/foo.png";
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
