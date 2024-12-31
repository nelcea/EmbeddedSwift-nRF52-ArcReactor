/// Logic that offers multiple types of effects on an LED ring
struct LedStripLogic {
  var ledStrip: LedStrip

  var ledTick = 0
  var currentLedMode: LedMode?

  // For pulsating
  var intensity = 1.0
  var direction = 0.9

  // For rotation
  var currentPixel = 0
  var currentColor = 0
  let rgbColors: [Color] = [.red, .green, .blue]

  mutating func allOff() {
    for i in 0..<STRIP_NUM_PIXELS {
      ledStrip.setPixel(at: Int(i), color: .off)
    }
  }

  mutating func tick() {
    ledTick += 1
    switch context.ledMode {
    case .off:
      if currentLedMode == nil || currentLedMode! != context.ledMode {
        allOff()
        ledStrip.refresh()
      }
    case .onePulsing, .allPulsing:
      if currentLedMode == nil || currentLedMode! != context.ledMode {
        if context.ledMode == .onePulsing {
          // We might be coming from another mode where some LED is on, turn all of them off
          allOff()
        }
      }

      if ledTick >= 4 {
        intensity *= direction
        if intensity < 0.05 {
          direction = 1.05
        } else if intensity > 0.30 {
          direction = 0.95
        }

        let color = Color(h: 0.0, s: 1.0, v: intensity)
        let numLeds = context.ledMode == .onePulsing ? 1 : STRIP_NUM_PIXELS
        for i in 0..<numLeds {
          ledStrip.setPixel(at: Int(i), color: color)
        }

        ledStrip.refresh()

        ledTick = 0
      }
    case .rgbRotation:
      if currentLedMode == nil || currentLedMode! != context.ledMode {
        // We might be coming from another mode where some LED is on, turn all of them off
        allOff()
      }
      if ledTick >= 10 {
        ledStrip.setPixel(at: currentPixel, color: .off)
        currentPixel = (currentPixel + 1) % Int(STRIP_NUM_PIXELS)
        if currentPixel == 0 {
          currentColor = (currentColor + 1) % 3
        }
        ledStrip.setPixel(at: currentPixel, color: rgbColors[currentColor])
        ledStrip.refresh()

        ledTick = 0
      }
    case .staticColor:
      if currentLedMode == nil || currentLedMode! != context.ledMode {
        let color = Color(r: 4, g: 6, b: 20)
        for i in 0..<STRIP_NUM_PIXELS {
          ledStrip.setPixel(at: Int(i), color: color)
        }
        ledStrip.refresh()
      }
    default:
      print("Invalid LED mode")
    }
    currentLedMode = context.ledMode
  }

}
