.pragma library

function getScale(mw, userScale) {
    if (mw <= 0) return 1.0;
    let r = mw / 1920.0;
    let baseScale = 1.0;

    if (r <= 1.0) {
        baseScale = Math.max(0.35, Math.pow(r, 0.85));
    } else {
        baseScale = Math.pow(r, 0.5);
    }

    return baseScale * (userScale !== undefined ? userScale : 1.0);
}

function s(val, scale) {
    return Math.round(val * scale);
}

function resolveIcon(ic) {
    if (!ic || ic === "") return "";
    if (ic.startsWith("/") || ic.startsWith("file://") || ic.startsWith("http")) return ic;
    return "image://theme/" + ic;
}
