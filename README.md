# Learn WebGL with Swift WASM

## Setup

### 1. Install Swift

First, Install Swiftly on your machine.
https://www.swift.org/install/macos/

Then, install Swift 6.2.3 using Swiftly.

```sh
$ swiftly install --use 6.2.3
```

### 2. Install Swift SDKs for WASM

Install Swift SDKs for WASM.

```sh
swift sdk install https://download.swift.org/swift-6.2.3-release/wasm-sdk/swift-6.2.3-RELEASE/swift-6.2.3-RELEASE_wasm.artifactbundle.tar.gz --checksum 394040ecd5260e68bb02f6c20aeede733b9b90702c2204e178f3e42413edad2a
```

Verify that Swift SDKs for WASM was installed.

```sh
$ swift sdk list
swift-6.2.3-RELEASE_wasm
swift-6.2.3-RELEASE_wasm-embedded
```

## How to run app

Build the app using the following command.

```sh
$ swift package --swift-sdk swift-6.2.3-RELEASE_wasm js --use-cdn
```
