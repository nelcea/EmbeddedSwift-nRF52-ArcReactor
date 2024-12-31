struct LedStrip {
  let strip: UnsafePointer<device>
  let numPixels: Int
  var pixels: [Color]

  init(strip: UnsafePointer<device>, numPixels: Int32) {
    self.strip = strip
    if device_is_ready(strip) {
      print("Found LED strip device")
    } else {
      fatalError("LED strip device is not ready")
    }
    self.numPixels = Int(numPixels)
    pixels = Array(repeating: .off, count: self.numPixels)
  }

  func refresh() {
    var pixelsToRefresh = pixels
    let rc = led_strip_update_rgb(strip, &pixelsToRefresh, numPixels)
    if rc != 0 {
      print("Couldn't update strip, error code \(rc)")
    }
  }

  mutating func setPixel(at index: Int, color: Color) {
    self.pixels[index] = color
  }
}
