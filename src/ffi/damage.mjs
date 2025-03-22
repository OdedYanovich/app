let damageCallback, id;

export function setDamageEvent(callback) {
    damageCallback = callback;
}
export function startDamageEvent() {
    id = setInterval(damageCallback, 1);
}
export function stopDamageEvent() {
    clearInterval(id);
}
