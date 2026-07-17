.pragma library

function getScale(mw, userScale) {
    if (mw <= 0) return 1.0;
    let r = mw / 1920.0;
    let baseScale = 1.0;
    
    if (r <= 1.0) {
        baseScale = Math.max(0.35, Math.pow(r, 0.85));
    } else {
        // SCALING UP:
        baseScale = Math.pow(r, 0.5);
    }
    
    // Multiply the screen-calculated scale by the user's uiScale
    return baseScale * (userScale !== undefined ? userScale : 1.0);
}

// Helper to easily round scaled values
function s(val, scale) {
    return Math.round(val * scale);
}

// Centralized registry for all widget dimensions and positional mathematics.
function getLayout(name, mx, my, mw, mh, userScale) {
    let scale = getScale(mw, userScale);

    let base = {
        "battery":   { w: s(801, scale), h: s(600, scale), rx: mw - s(821, scale), ry: s(70, scale), comp: "battery/BatteryPopup.qml" },
        "hidden":    { w: 1, h: 1, rx: -5000 - mx, ry: -5000 - my, comp: "" } 
    };

    if (!base[name]) return null;
    
    let t = base[name];
    // Calculate final absolute coordinates based on active monitor offset
    t.x = mx + t.rx;
    t.y = my + t.ry;
    
    return t;
}

// -----------------------------------------------------------------------------
// Separate Layout function for the Notification OSD popups
// -----------------------------------------------------------------------------
function getPopupLayout(mw, userScale) {
    let scale = getScale(mw, userScale);
    return {
        // You can change dimensions and position here
        w: s(350, scale),
        marginTop: s(44, scale),
        marginRight: s(20, scale),
        
        // We can also centralize internal UI scaling sizes here if desired
        spacing: s(12, scale),
        radius: s(14, scale),
        padding: s(12, scale)
    };
}
