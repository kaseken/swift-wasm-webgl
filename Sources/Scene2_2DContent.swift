import JavaScriptKit

// Tutorial 2: Adding 2D content to a WebGL context
// https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Adding_2D_content_to_a_WebGL_context

@MainActor
func runScene2() {
    let console = JSObject.global.console
    let document = JSObject.global.document
    let canvasElement = document.getElementById("canvas-scene2")
    let gl = canvasElement.getContext("webgl")

    // Define shader sources
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

    // Create and compile vertex shader
    let VERTEX_SHADER: Int32 = 0x8B31
    let vertexShader = gl.createShader(VERTEX_SHADER)
    _ = gl.shaderSource(vertexShader, vsSource)
    _ = gl.compileShader(vertexShader)

    let COMPILE_STATUS: Int32 = 0x8B81
    let vCompiled = gl.getShaderParameter(vertexShader, COMPILE_STATUS)

    guard let compiled = vCompiled.boolean, compiled else {
        let info = gl.getShaderInfoLog(vertexShader)
        _ = console.error("Vertex shader compilation failed:", info)
        return
    }

    // Create and compile fragment shader
    let FRAGMENT_SHADER: Int32 = 0x8B30
    let fragmentShader = gl.createShader(FRAGMENT_SHADER)
    _ = gl.shaderSource(fragmentShader, fsSource)
    _ = gl.compileShader(fragmentShader)

    let fCompiled = gl.getShaderParameter(fragmentShader, COMPILE_STATUS)

    guard let fCompiledBool = fCompiled.boolean, fCompiledBool else {
        let info = gl.getShaderInfoLog(fragmentShader)
        _ = console.error("Fragment shader compilation failed:", info)
        return
    }

    // Create and link shader program
    let shaderProgram = gl.createProgram()
    _ = gl.attachShader(shaderProgram, vertexShader)
    _ = gl.attachShader(shaderProgram, fragmentShader)
    _ = gl.linkProgram(shaderProgram)

    let LINK_STATUS: Int32 = 0x8B82
    let linked = gl.getProgramParameter(shaderProgram, LINK_STATUS)

    guard let linkedBool = linked.boolean, linkedBool else {
        let info = gl.getProgramInfoLog(shaderProgram)
        _ = console.error("Shader program linking failed:", info)
        return
    }

    // Create position buffer
    let positionBuffer = initPositionBuffer(gl: gl)

    // Get attribute and uniform locations
    let vertexPosition = gl.getAttribLocation(shaderProgram, "aVertexPosition")
    let projectionMatrix = gl.getUniformLocation(shaderProgram, "uProjectionMatrix")
    let modelViewMatrix = gl.getUniformLocation(shaderProgram, "uModelViewMatrix")

    // Draw the scene
    drawScene(
        gl: gl,
        programInfo: (
            program: shaderProgram,
            vertexPosition: vertexPosition,
            uniformLocations: (projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix)
        ),
        positionBuffer: positionBuffer
    )
}

// Initialize position buffer for the square
@MainActor
func initPositionBuffer(gl: JSValue) -> JSValue {
    let positionBuffer = gl.createBuffer()

    let ARRAY_BUFFER: Int32 = 0x8892
    _ = gl.bindBuffer(ARRAY_BUFFER, positionBuffer)

    let positions: [Float32] = [
        1.0,  1.0,
        -1.0,  1.0,
        1.0, -1.0,
        -1.0, -1.0,
    ]

    let positionsArray = JSTypedArray<Float32>(positions)

    let STATIC_DRAW: Int32 = 0x88E4
    _ = gl.bufferData(ARRAY_BUFFER, positionsArray, STATIC_DRAW)

    return positionBuffer
}

// Draw the scene
@MainActor
func drawScene(
    gl: JSValue,
    programInfo: (
        program: JSValue,
        vertexPosition: JSValue,
        uniformLocations: (projectionMatrix: JSValue, modelViewMatrix: JSValue)
    ),
    positionBuffer: JSValue
) {
    let console = JSObject.global.console

    // Clear the canvas
    _ = gl.clearColor(0.0, 0.0, 0.0, 1.0)
    _ = gl.clearDepth(1.0)
    _ = gl.enable(0x0B71) // DEPTH_TEST
    _ = gl.depthFunc(0x0203) // LEQUAL

    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    let DEPTH_BUFFER_BIT: Int32 = 0x0000_0100
    _ = gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT)

    // Create projection matrix using gl-matrix
    guard let mat4 = JSObject.global.mat4.object else {
        _ = console.error("mat4 not found! Make sure gl-matrix is loaded.")
        return
    }

    let projectionMatrix = mat4.create!()
    let fieldOfView: Float = 45 * .pi / 180
    let canvas = gl.canvas.object!
    let aspect = canvas.clientWidth.number! / canvas.clientHeight.number!
    let zNear: Float = 0.1
    let zFar: Float = 100.0
    _ = mat4.perspective!(projectionMatrix, fieldOfView, aspect, zNear, zFar)

    // Create model-view matrix
    let modelViewMatrix = mat4.create!()
    _ = mat4.translate!(
        modelViewMatrix,
        modelViewMatrix,
        JSObject.global.Array.object!.of!(-0.0, 0.0, -6.0)
    )

    // Bind position buffer and configure vertex attributes
    let ARRAY_BUFFER: Int32 = 0x8892
    _ = gl.bindBuffer(ARRAY_BUFFER, positionBuffer)

    let numComponents: Int32 = 2
    let type: Int32 = 0x1406 // FLOAT
    let normalize = false
    let stride: Int32 = 0
    let offset: Int32 = 0

    _ = gl.vertexAttribPointer(
        programInfo.vertexPosition,
        numComponents,
        type,
        normalize,
        stride,
        offset
    )
    _ = gl.enableVertexAttribArray(programInfo.vertexPosition)

    // Use shader program and set uniforms
    _ = gl.useProgram(programInfo.program)

    _ = gl.uniformMatrix4fv(
        programInfo.uniformLocations.projectionMatrix,
        false,
        projectionMatrix
    )

    _ = gl.uniformMatrix4fv(
        programInfo.uniformLocations.modelViewMatrix,
        false,
        modelViewMatrix
    )

    // Draw the square
    let TRIANGLE_STRIP: Int32 = 0x0005
    let vertexCount: Int32 = 4
    _ = gl.drawArrays(TRIANGLE_STRIP, 0, vertexCount)
}
