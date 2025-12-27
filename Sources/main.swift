import JavaScriptKit

@main
struct WebGLDemo {
    static func main() {
        initWebGL()
    }
}

@MainActor
func initWebGL() {
    let document = JSObject.global.document
    let canvasElement = document.getElementById("gl-canvas")
    let gl = canvasElement.getContext("webgl")
    _ = gl.clearColor(0.0, 0.0, 0.0, 1.0)
    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    _ = gl.clear(COLOR_BUFFER_BIT)
}
