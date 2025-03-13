export function create(size, init) {
    return Array.from({ length: size }, (_, index) => init(index));
}
export function map(array, fun) {
    return array.map(fun);
}
export function iter(array, fun) {
    array.forEach((element, index) => fun(element, index));
}

export function get(array, index) {
    return array[index];
}

export function push(array, val) {
    array.push(val);
    return array;
}
export function popBack(array) {
    const first = array.shift();
    return [array, first];
}

export function splice(array, index, amount) {
    let removed = array.splice(index, amount);
    return [array, removed];
}
export function length(array) {
    return array.length;
}
export function set(array, index, val) {
    array[index] = val;
    return array;
}
// Remove all that is below
export function indexArray(size) {
    return [...Array(size).keys()];
}
export function setLast(array, val) {
    array[val] += 1;
    return array;
}

export function last(array) {
    return array.pop();
}
