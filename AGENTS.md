# Summary

Swift library using SwiftGD for generating pixelized png bilboards. It needs to work on MacOS and Linux. It is distributed with Swift Package Manager.

# Project Structure
All new classes/structs/enums put in appropriate folder in separate file. Do not create long files with multiple definitions inside. Although you can add type's extensions in the same file as extended type. If you need extend some object to protocol, name file ObjectType+ProtocolName.swift.

# Available tools
You have docker with images:
- Swift for Linux: `swift:6.1`

# Bulding project
- Run `swift build` to build the project on local MacOS
- Run `docker run --rm -t  -v "$PWD":/workspace -w /workspace swift:6.1 swift build` to build the project in linux Swift 6.1 Remember to clean build folder (rm -rf .build) when building for different platform.

# Unit Testing
- Run `swift test` for local unit tests
- Run `docker build -t bilboard-test . && docker run --rm bilboard-test` for unit test on linux

# Change commit
Never commit anything, let user review changes.
