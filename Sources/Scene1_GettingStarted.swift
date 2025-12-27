import JavaScriptKit

// Tutorial 1: Getting Started with WebGL
// https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Getting_started_with_WebGL

@MainActor
func runScene1() {
    let document = JSObject.global.document
    let canvasElement = document.getElementById("canvas-scene1")
    let gl = canvasElement.getContext("webgl")

    _ = gl.clearColor(0.0, 0.0, 0.0, 1.0)
    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    _ = gl.clear(COLOR_BUFFER_BIT)
}
