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

function getLayout(name, mx, my, mw, mh, userScale) {
    let scale = getScale(mw, userScale);

    let sc = (v) => Math.round(v * scale);

    let centerX = (w) => Math.round((mw - w) / 2);

    let layouts = {
        "hidden":  { w: 1, h: 1, rx: -5000 - mx, ry: -5000 - my, comp: "" },
        "calendar": { w: sc(680), h: sc(520), rx: centerX(sc(680)), ry: sc(50), comp: "" },
        "clock":    { w: sc(480), h: sc(380), rx: centerX(sc(480)), ry: sc(50), comp: "" },
        "notifs":   { w: sc(640), h: sc(500), rx: centerX(sc(640)), ry: sc(50), comp: "" },
    };

    let entry = layouts[name];
    if (!entry) {
        let w = sc(680);
        let h = sc(500);
        entry = { w: w, h: h, rx: centerX(w), ry: sc(50), comp: "" };
    }

    return {
        w: entry.w,
        h: entry.h,
        rx: entry.rx,
        ry: entry.ry,
        x: mx + entry.rx,
        y: my + entry.ry,
        comp: entry.comp
    };
}

function resolveIcon(ic) {
    if (!ic || ic === "") return "";
    if (ic.startsWith("/") || ic.startsWith("file://") || ic.startsWith("http")) return ic;
    return "image://theme/" + ic;
}
