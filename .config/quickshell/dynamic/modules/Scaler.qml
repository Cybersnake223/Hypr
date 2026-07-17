import QtQml
import "WindowRegistry.js" as LayoutMath

QtObject {
    id: root

    property real currentWidth: 1920.0
    property real uiScale: 1.0

    property real baseScale: LayoutMath.getScale(currentWidth, uiScale)

    function s(val) {
        return LayoutMath.s(val, baseScale);
    }
}
