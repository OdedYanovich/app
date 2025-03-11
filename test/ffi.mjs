

export function newArray(rows, columns) {
    return Array(rows).fill().map(() => Array(columns).fill(0));
}
