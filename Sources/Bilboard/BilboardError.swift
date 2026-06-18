public enum BilboardError: Error {
    case invalidCanvasSize
    case fontResourceMissing
    case fontResourceUnreadable
    case imageCreationFailed
    case pngExportFailed
}