import JavaScriptKit

// Tutorial 2: Adding 2D content to a WebGL context
// https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Adding_2D_content_to_a_WebGL_context

@MainActor
func runScene2() {
    let console = JSObject.global.console
    let document = JSObject.global.document
    let canvasElement = document.getElementById("canvas-scene2")
    let gl = canvasElement.getContext("webgl")

    // Step 1: Define shader sources
    let vsSource = """
    attribute vec4 aVertexPosition;
    uniform mat4 uModelViewMatrix;
    uniform mat4 uProjectionMatrix;
    void main() {
        gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
    }
    """

    let fsSource = """
    void main() {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    }
    """

    _ = console.log("Step 1: Shader sources defined")
    _ = console.log("Vertex shader:", vsSource)
    _ = console.log("Fragment shader:", fsSource)

    // TODO: Compile shaders
    _ = gl.clearColor(0.2, 0.2, 0.3, 1.0)
    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    _ = gl.clear(COLOR_BUFFER_BIT)
}
