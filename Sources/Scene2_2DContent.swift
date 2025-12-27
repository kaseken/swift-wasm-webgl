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

    // Step 6: Get attribute and uniform locations
    let vertexPosition = gl.getAttribLocation(shaderProgram, "aVertexPosition")
    _ = console.log("Step 6: Got aVertexPosition location:", vertexPosition)

    let projectionMatrix = gl.getUniformLocation(shaderProgram, "uProjectionMatrix")
    _ = console.log("Step 6: Got uProjectionMatrix location:", projectionMatrix)

    let modelViewMatrix = gl.getUniformLocation(shaderProgram, "uModelViewMatrix")
    _ = console.log("Step 6: Got uModelViewMatrix location:", modelViewMatrix)

    // Step 7: Draw the scene
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
    _ = console.log("Step 7: Drawing scene...")

    // Step 7.1: Clear the canvas
    _ = gl.clearColor(0.0, 0.0, 0.0, 1.0)
    _ = gl.clearDepth(1.0)
    _ = gl.enable(0x0B71) // DEPTH_TEST
    _ = gl.depthFunc(0x0203) // LEQUAL

    let COLOR_BUFFER_BIT: Int32 = 0x0000_4000
    let DEPTH_BUFFER_BIT: Int32 = 0x0000_0100
    _ = gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT)
    _ = console.log("  Step 7.1: Cleared canvas")

    // Step 7.2: Create projection matrix
    _ = console.log("  Step 7.2: Checking for mat4...")

    // gl-matrix exports mat4 directly to window, not under glMatrix namespace
    let mat4Value = JSObject.global.mat4
    _ = console.log("  Step 7.2: mat4 value:", mat4Value)
    _ = console.log("  Step 7.2: mat4 isNull:", mat4Value.isNull)
    _ = console.log("  Step 7.2: mat4 isUndefined:", mat4Value.isUndefined)

    guard let mat4 = mat4Value.object else {
        _ = console.error("mat4 not found! Make sure gl-matrix is loaded.")
        return
    }

    _ = console.log("  Step 7.2: Got mat4 object")

    let projectionMatrix = mat4.create!()
    _ = console.log("  Step 7.2: Created projection matrix:", projectionMatrix)

    let fieldOfView: Float = 45 * .pi / 180 // in radians
    let canvas = gl.canvas.object!
    let aspect = canvas.clientWidth.number! / canvas.clientHeight.number!
    let zNear: Float = 0.1
    let zFar: Float = 100.0

    _ = mat4.perspective!(projectionMatrix, fieldOfView, aspect, zNear, zFar)
    _ = console.log("  Step 7.2: Set perspective projection")

    // Step 7.3: Create model-view matrix
    let modelViewMatrix = mat4.create!()
    _ = console.log("  Step 7.3: Created model-view matrix:", modelViewMatrix)

    // Translate the square
    _ = mat4.translate!(
        modelViewMatrix,
        modelViewMatrix,
        JSObject.global.Array.object!.of!(-0.0, 0.0, -6.0)
    )
    _ = console.log("  Step 7.3: Translated model-view matrix")

    // Step 7.4: Bind position buffer and configure vertex attributes
    let ARRAY_BUFFER: Int32 = 0x8892
    _ = gl.bindBuffer(ARRAY_BUFFER, positionBuffer)
    _ = console.log("  Step 7.4: Bound position buffer")

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
    _ = console.log("  Step 7.4: Configured vertex attribute pointer")

    _ = gl.enableVertexAttribArray(programInfo.vertexPosition)
    _ = console.log("  Step 7.4: Enabled vertex attribute array")

    // Step 7.5: Use shader program and set uniforms
    _ = gl.useProgram(programInfo.program)
    _ = console.log("  Step 7.5: Using shader program")

    _ = gl.uniformMatrix4fv(
        programInfo.uniformLocations.projectionMatrix,
        false,
        projectionMatrix
    )
    _ = console.log("  Step 7.5: Set projection matrix uniform")

    _ = gl.uniformMatrix4fv(
        programInfo.uniformLocations.modelViewMatrix,
        false,
        modelViewMatrix
    )
    _ = console.log("  Step 7.5: Set model-view matrix uniform")

    // Step 7.6: Draw the square
    let TRIANGLE_STRIP: Int32 = 0x0005
    let vertexCount: Int32 = 4
    _ = gl.drawArrays(TRIANGLE_STRIP, 0, vertexCount)
    _ = console.log("  Step 7.6: Drew square with drawArrays")
}
