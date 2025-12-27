import JavaScriptKit

@MainActor
func run2DContent() {
    let console = JSObject.global.console
    let document = JSObject.global.document
    let canvasElement = document.getElementById("canvas")
    let gl = canvasElement.getContext("webgl")

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

    guard let shaderProgram = initShaderProgram(gl: gl, vsSource: vsSource, fsSource: fsSource) else {
        _ = console.error("Failed to initialize shader program")
        return
    }

    let positionBuffer = initPositionBuffer(gl: gl)

    let programInfo = (
        program: shaderProgram,
        vertexPosition: gl.getAttribLocation(shaderProgram, "aVertexPosition"),
        uniformLocations: (
            projectionMatrix: gl.getUniformLocation(shaderProgram, "uProjectionMatrix"),
            modelViewMatrix: gl.getUniformLocation(shaderProgram, "uModelViewMatrix"),
        ),
    )

    drawScene(gl: gl, programInfo: programInfo, positionBuffer: positionBuffer)
}

// Initialize shader program
@MainActor
private func initShaderProgram(gl: JSValue, vsSource: String, fsSource: String) -> JSValue? {
    let console = JSObject.global.console

    guard let vertexShader = compileShader(gl: gl, type: 0x8B31, source: vsSource) else {
        return nil
    }

    guard let fragmentShader = compileShader(gl: gl, type: 0x8B30, source: fsSource) else {
        return nil
    }

    let shaderProgram = gl.createProgram()
    _ = gl.attachShader(shaderProgram, vertexShader)
    _ = gl.attachShader(shaderProgram, fragmentShader)
    _ = gl.linkProgram(shaderProgram)

    let LINK_STATUS: Int32 = 0x8B82
    let linked = gl.getProgramParameter(shaderProgram, LINK_STATUS)

    guard let linkedBool = linked.boolean, linkedBool else {
        let info = gl.getProgramInfoLog(shaderProgram)
        _ = console.error("Shader program linking failed:", info)
        return nil
    }

    return shaderProgram
}

// Compile a shader
@MainActor
private func compileShader(gl: JSValue, type: Int32, source: String) -> JSValue? {
    let console = JSObject.global.console

    let shader = gl.createShader(type)
    _ = gl.shaderSource(shader, source)
    _ = gl.compileShader(shader)

    let COMPILE_STATUS: Int32 = 0x8B81
    let compiled = gl.getShaderParameter(shader, COMPILE_STATUS)

    guard let compiledBool = compiled.boolean, compiledBool else {
        let info = gl.getShaderInfoLog(shader)
        let shaderType = type == 0x8B31 ? "vertex" : "fragment"
        _ = console.error("\(shaderType) shader compilation failed:", info)
        _ = gl.deleteShader(shader)
        return nil
    }

    return shader
}

// Initialize position buffer for the square
@MainActor
private func initPositionBuffer(gl: JSValue) -> JSValue {
    let positionBuffer = gl.createBuffer()

    let ARRAY_BUFFER: Int32 = 0x8892
    _ = gl.bindBuffer(ARRAY_BUFFER, positionBuffer)

    let positions: [Float32] = [
        1.0, 1.0,
        -1.0, 1.0,
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
private func drawScene(
    gl: JSValue,
    programInfo: (
        program: JSValue,
        vertexPosition: JSValue,
        uniformLocations: (projectionMatrix: JSValue, modelViewMatrix: JSValue),
    ),
    positionBuffer: JSValue,
) {
    let console = JSObject.global.console

    clearCanvas(gl: gl)

    guard let mat4 = JSObject.global.mat4.object else {
        _ = console.error("mat4 not found! Make sure gl-matrix is loaded.")
        return
    }

    let projectionMatrix = createProjectionMatrix(gl: gl, mat4: mat4)
    let modelViewMatrix = createModelViewMatrix(mat4: mat4)

    setPositionAttribute(gl: gl, positionBuffer: positionBuffer, vertexPosition: programInfo.vertexPosition)

    _ = gl.useProgram(programInfo.program)
    setUniforms(gl: gl, uniformLocations: programInfo.uniformLocations, projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix)

    let TRIANGLE_STRIP: Int32 = 0x0005
    let vertexCount: Int32 = 4
    _ = gl.drawArrays(TRIANGLE_STRIP, 0, vertexCount)
}

// Clear the canvas
@MainActor
private func clearCanvas(gl: JSValue) {
    _ = gl.clearColor(0.0, 0.0, 0.0, 1.0)
    _ = gl.clearDepth(1.0)
    _ = gl.enable(0x0B71) // DEPTH_TEST
    _ = gl.depthFunc(0x0203) // LEQUAL

    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    let DEPTH_BUFFER_BIT: Int32 = 0x0000_0100
    _ = gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT)
}

// Create projection matrix
@MainActor
private func createProjectionMatrix(gl: JSValue, mat4: JSObject) -> JSValue {
    let projectionMatrix = mat4.create!()
    let fieldOfView: Float = 45 * .pi / 180
    let canvas = gl.canvas.object!
    let aspect = canvas.clientWidth.number! / canvas.clientHeight.number!
    let zNear: Float = 0.1
    let zFar: Float = 100.0
    _ = mat4.perspective!(projectionMatrix, fieldOfView, aspect, zNear, zFar)
    return projectionMatrix
}

// Create model-view matrix
@MainActor
private func createModelViewMatrix(mat4: JSObject) -> JSValue {
    let modelViewMatrix = mat4.create!()
    _ = mat4.translate!(
        modelViewMatrix,
        modelViewMatrix,
        JSObject.global.Array.object!.of!(-0.0, 0.0, -6.0),
    )
    return modelViewMatrix
}

// Set position attribute
@MainActor
private func setPositionAttribute(gl: JSValue, positionBuffer: JSValue, vertexPosition: JSValue) {
    let ARRAY_BUFFER: Int32 = 0x8892
    _ = gl.bindBuffer(ARRAY_BUFFER, positionBuffer)

    let numComponents: Int32 = 2
    let type: Int32 = 0x1406 // FLOAT
    let normalize = false
    let stride: Int32 = 0
    let offset: Int32 = 0

    _ = gl.vertexAttribPointer(vertexPosition, numComponents, type, normalize, stride, offset)
    _ = gl.enableVertexAttribArray(vertexPosition)
}

// Set uniform matrices
@MainActor
private func setUniforms(
    gl: JSValue,
    uniformLocations: (projectionMatrix: JSValue, modelViewMatrix: JSValue),
    projectionMatrix: JSValue,
    modelViewMatrix: JSValue,
) {
    _ = gl.uniformMatrix4fv(uniformLocations.projectionMatrix, false, projectionMatrix)
    _ = gl.uniformMatrix4fv(uniformLocations.modelViewMatrix, false, modelViewMatrix)
}
