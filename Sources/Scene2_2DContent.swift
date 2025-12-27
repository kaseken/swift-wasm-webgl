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

    // Step 3: Create and compile fragment shader
    let FRAGMENT_SHADER: Int32 = 0x8B30
    let fragmentShader = gl.createShader(FRAGMENT_SHADER)
    _ = console.log("Step 3: Created fragment shader:", fragmentShader)

    _ = gl.shaderSource(fragmentShader, fsSource)
    _ = gl.compileShader(fragmentShader)
    _ = console.log("Step 3: Compiled fragment shader")

    // Check if compilation was successful
    let fCompiled = gl.getShaderParameter(fragmentShader, COMPILE_STATUS)
    _ = console.log("Step 3: Fragment shader compiled successfully?", fCompiled)

    guard let fCompiledBool = fCompiled.boolean, fCompiledBool else {
        let info = gl.getShaderInfoLog(fragmentShader)
        _ = console.error("Fragment shader compilation failed:", info)
        return
    }

    // Step 4: Create and link shader program
    let shaderProgram = gl.createProgram()
    _ = console.log("Step 4: Created shader program:", shaderProgram)

    _ = gl.attachShader(shaderProgram, vertexShader)
    _ = gl.attachShader(shaderProgram, fragmentShader)
    _ = console.log("Step 4: Attached shaders to program")

    _ = gl.linkProgram(shaderProgram)
    _ = console.log("Step 4: Linked program")

    // Check if linking was successful
    let LINK_STATUS: Int32 = 0x8B82
    let linked = gl.getProgramParameter(shaderProgram, LINK_STATUS)
    _ = console.log("Step 4: Program linked successfully?", linked)

    guard let linkedBool = linked.boolean, linkedBool else {
        let info = gl.getProgramInfoLog(shaderProgram)
        _ = console.error("Shader program linking failed:", info)
        return
    }

    _ = console.log("Step 4: Shader program ready!")

    // Step 5: Create position buffer
    let positionBuffer = initPositionBuffer(gl: gl)
    _ = console.log("Step 5: Position buffer created:", positionBuffer)

    // TODO: Draw the scene
    _ = gl.clearColor(0.2, 0.2, 0.3, 1.0)
    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    _ = gl.clear(COLOR_BUFFER_BIT)
}

// Initialize position buffer for the square
@MainActor
func initPositionBuffer(gl: JSValue) -> JSValue {
    let console = JSObject.global.console

    // Step 5.1: Create a buffer
    let positionBuffer = gl.createBuffer()
    _ = console.log("  Step 5.1: Created buffer:", positionBuffer)

    // Step 5.2: Bind the buffer to ARRAY_BUFFER
    let ARRAY_BUFFER: Int32 = 0x8892
    _ = gl.bindBuffer(ARRAY_BUFFER, positionBuffer)
    _ = console.log("  Step 5.2: Bound buffer to ARRAY_BUFFER")

    // Step 5.3: Define vertex positions
    let positions: [Float32] = [
        1.0,  1.0,   // top right
        -1.0,  1.0,   // top left
        1.0, -1.0,   // bottom right
        -1.0, -1.0,   // bottom left
    ]
    _ = console.log("  Step 5.3: Defined positions (count:", positions.count, ")")

    // Step 5.4: Create Float32Array from positions
    _ = console.log("  Step 5.4: Creating Float32Array...")
    let positionsArray = JSTypedArray<Float32>(positions)
    _ = console.log("  Step 5.4: Created Float32Array:", positionsArray.jsObject)

    // Step 5.5: Upload data to GPU
    let STATIC_DRAW: Int32 = 0x88E4
    _ = gl.bufferData(ARRAY_BUFFER, positionsArray, STATIC_DRAW)
    _ = console.log("  Step 5.5: Uploaded data to GPU")

    return positionBuffer
}
