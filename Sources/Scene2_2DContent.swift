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

    // Step 2: Create and compile vertex shader
    let VERTEX_SHADER: Int32 = 0x8B31
    let vertexShader = gl.createShader(VERTEX_SHADER)
    _ = console.log("Step 2: Created vertex shader:", vertexShader)

    _ = gl.shaderSource(vertexShader, vsSource)
    _ = gl.compileShader(vertexShader)
    _ = console.log("Step 2: Compiled vertex shader")

    // Check if compilation was successful
    let COMPILE_STATUS: Int32 = 0x8B81
    let vCompiled = gl.getShaderParameter(vertexShader, COMPILE_STATUS)
    _ = console.log("Step 2: Vertex shader compiled successfully?", vCompiled)

    guard let compiled = vCompiled.boolean, compiled else {
        let info = gl.getShaderInfoLog(vertexShader)
        _ = console.error("Vertex shader compilation failed:", info)
        return
    }

    // TODO: Compile fragment shader
    _ = gl.clearColor(0.2, 0.2, 0.3, 1.0)
    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    _ = gl.clear(COLOR_BUFFER_BIT)
}
