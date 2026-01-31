#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 selectionRect; // (x, y, width, height)
    float dimOpacity;
    vec2 screenSize;
    float borderRadius;
    float outlineThickness;
};

float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 halfSize = selectionRect.zw / 2.0;
    vec2 center = selectionRect.xy + halfSize;
    vec2 pixelPos = qt_TexCoord0 * screenSize;
    vec2 p = pixelPos - center;

    float dist = sdRoundedBox(p, halfSize, borderRadius);

    bool insideFilledArea = dist <= 0.0;

    bool insideOutline = dist > 0.0 && dist <= outlineThickness;

    if (insideFilledArea) {
        fragColor = vec4(0.0);
    } else if (insideOutline) {
        fragColor = vec4(1.0, 1.0, 1.0, 1.0 * qt_Opacity);
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, dimOpacity * qt_Opacity);
    }
}
