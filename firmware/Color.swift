typealias Color = led_rgb

extension Color {
  init(r: UInt8, g: UInt8, b: UInt8) {
    self.init()
    self.scratch = 0
    self.r = r
    self.g = g
    self.b = b
  }
}

extension Color {
  static let off = led_rgb(r: 0, g: 0, b: 0)
  static let white = led_rgb(r: 255, g: 255, b: 255)
  static let red = led_rgb(r: 255, g: 0, b: 0)
  static let green = led_rgb(r: 0, g: 255, b: 0)
  static let blue = led_rgb(r: 0, g: 0, b: 255)
}

extension Color {
  // Based on https://www.cs.rit.edu/~ncs/color/t_convert.html and https://gist.github.com/FredrikSjoberg/cdea97af68c6bdb0a89e3aba57a966ce
  static func hsvToRgb(h: Double, s: Double, v: Double) -> (r: UInt8, g: UInt8, b: UInt8) {
    var f: Double
    var p: Double
    var q: Double
    var t: Double
    if s == 0 {
      // achromatic (grey)
      return (r: UInt8(v * 255), g: UInt8(v * 255), b: UInt8(v * 255))
    }
    let sector = h / 60
    let i = Int(sector) % 6
    f = sector - Double(i)  // factorial part of h
    p = v * (1 - s)
    q = v * (1 - s * f)
    t = v * (1 - s * (1 - f))

    switch i {
    case 0:
      return (r: UInt8(v * 255), g: UInt8(t * 255), b: UInt8(p * 255))
    case 1:
      return (r: UInt8(q * 255), g: UInt8(v * 255), b: UInt8(p * 255))

    case 2:
      return (r: UInt8(p * 255), g: UInt8(v * 255), b: UInt8(t * 255))
    case 3:
      return (r: UInt8(p * 255), g: UInt8(q * 255), b: UInt8(v * 255))
    case 4:
      return (r: UInt8(t * 255), g: UInt8(p * 255), b: UInt8(v * 255))
    default:  // case 5:
      return (r: UInt8(v * 255), g: UInt8(p * 255), b: UInt8(q * 255))
    }
  }

  init(h: Double, s: Double, v: Double) {
    let rgb = Self.hsvToRgb(h: h, s: s, v: v)
    self.init(r: rgb.0, g: rgb.1, b: rgb.2)
  }
}
