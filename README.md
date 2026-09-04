# Bilboard

Bilboard is a Swift Package for rendering pixelized PNG billboard images on macOS and Linux.
It uses SwiftGD/libgd under the hood, but exposes a small Swift API centered around a virtual-pixel grid.

One virtual pixel is rendered as a 2x2 lit block with spacing around it, which gives the final image the LED billboard look.

## Requirements

- Swift 6.1+
- libgd

Install libgd locally before building:

```bash
brew install gd
```

For Debian/Ubuntu based Linux:

```bash
apt-get update && apt-get install -y libgd-dev
```

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tomieq/Bilboard.git", from: "1.0.0")
]
```

Then add the product to your target:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "Bilboard", package: "Bilboard")
    ]
)
```

For an iOS app, depend on the UIKit-backed product instead. It has no SwiftGD or libgd dependency:

```swift
.target(
    name: "MyiOSApp",
    dependencies: [
        .product(name: "BilboardMobile", package: "Bilboard")
    ]
)
```

## Core Concepts

- `horizontalVirtualPixelsAmount` is the board width in virtual pixels.
- `imageHeightInLines` is the text height in 10-virtual-pixel rows.
- Text and shapes are drawn into the virtual-pixel grid first.
- `getImage()` renders the final board and returns PNG `Data`.

## Public API

### `Bilboard`

Create a board:

```swift
let bilboard = try Bilboard(
    horizontalVirtualPixelsAmount: 150,
    imageHeightInLines: 4,
    color: .red,
    borderActive: true
)
```

Available initializer parameters:

- `horizontalVirtualPixelsAmount: Int` - board width in virtual pixels.
- `imageHeightInLines: Int` - number of 10-pixel text rows.
- `color: BilboardColor` - board color palette. Default is `.red`.
- `borderActive: Bool` - enables the rounded outer frame.

Drawing methods:

- `setBigPixel(_ x: Int, _ y: Int)`
- `addLine(x1:y1:x2:y2:separator:)`
- `printLetter(_ letter:x:y:)`
- `addSentenceLeft(_ sentence:xOffset:yOffset:)`
- `addSentenceRight(_ sentence:xOffsetRight:yOffset:)`
- `addSentenceCenter(_ sentence:xOffsetRight:yOffset:)`
- `addMultiSentence(_ sentence:xOffset:yOffset:)`
- `fillRandom(granularity:)`
- `drawFromPattern(_ pattern:x:y:)`
- `getImage() throws -> Data`

### `BilboardMobile` (iOS)

`BilboardMobile` provides the same `Bilboard`, `BilboardColor`, and drawing APIs as the PNG product, but uses UIKit to return a native `UIImage`. Its `getImage()` method does not throw:

```swift
import BilboardMobile
import SwiftUI

let bilboard = try Bilboard(
    horizontalVirtualPixelsAmount: 120,
    imageHeightInLines: 3,
    color: .blue,
    borderActive: true
)
bilboard.addSentenceCenter("Status: OK", yOffset: 1)

let image = Image(uiImage: bilboard.getImage())
    .interpolation(.none)
```

### `BilboardColor`

Supported color palettes:

- `.red`
- `.green`
- `.orange`
- `.darkgray`
- `.lightgray`
- `.blue`
- `.whiteOnBlue`
- `.sea`
- `.violet`
- `.yellow`
- `.pink`
- `.idemia`
- `.streetGreen`

### `BilboardError`

Possible thrown errors:

- `.invalidCanvasSize`
- `.fontResourceMissing`
- `.fontResourceUnreadable`
- `.imageCreationFailed`
- `.pngExportFailed`

## Usage

### Render text and export PNG data

```swift
import Foundation
import Bilboard

let bilboard = try Bilboard(
    horizontalVirtualPixelsAmount: 120,
    imageHeightInLines: 3,
    color: .blue,
    borderActive: true
)

bilboard.addSentenceCenter("Swift Server", yOffset: 0)
bilboard.addSentenceCenter("Status: OK", yOffset: 1)

let pngData = try bilboard.getImage()
try pngData.write(to: URL(fileURLWithPath: "/tmp/bilboard.png"))
```

### Draw custom shapes on the board

```swift
let bilboard = try Bilboard(horizontalVirtualPixelsAmount: 80, imageHeightInLines: 2)

bilboard.addLine(x1: 0, y1: 0, x2: 20, y2: 0)
bilboard.addLine(x1: 0, y1: 0, x2: 0, y2: 10)
bilboard.setBigPixel(10, 5)

let pngData = try bilboard.getImage()
```

### Draw a pattern manually

Any non-space character is treated as a lit virtual pixel:

```swift
let pattern = """
  xxx
 xxxxx
xxxxxxx
 xxxxx
  xxx
"""

let bilboard = try Bilboard(horizontalVirtualPixelsAmount: 60, imageHeightInLines: 2)
bilboard.drawFromPattern(pattern, x: 5, y: 3)
```

## Text Layout Notes

- Text methods position glyphs on the virtual-pixel grid.
- `yOffset` is measured in text lines, where one line is 10 virtual pixels tall.
- Letters are separated by one virtual pixel.
- `addMultiSentence` wraps long text to fit the configured board width.

## Testing

Run tests locally:

```bash
swift test
```

Run tests in Docker on Linux:

```bash
docker build -t bilboard-test .
docker run --rm bilboard-test
```
