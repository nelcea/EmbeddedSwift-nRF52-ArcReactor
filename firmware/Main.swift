let handleEvent: @convention(c) (UnsafeMutablePointer<lv_event_t>?) -> Void = { e in
  if e!.pointee.target.pointee.parent == context.screens[3].pointer {
    context.currentScreen = 0
    context.screenRotation = true
  } else {
    context.screenRotation = false
    context.currentScreen = 3
  }
}

class Context {
  var screenRotation = true
  var screens: [LVGLScreen] = []
  var currentScreen: UInt8 = 0

  var ledMode = LedMode.rgbRotation

  func setupScreens() {

    screens = [LVGLScreen(), LVGLScreen(), LVGLScreen(), LVGLScreen()]

    screens[0].setActive()

    let pragmaLogo = LVGLImage(parent: screens[0], imageDescription: PragmaLogo.description)
    let swiftLogo = LVGLImage(parent: screens[1], imageDescription: SwiftLogo.description)
    let nelceaLogo = LVGLImage(parent: screens[2], imageDescription: NelceaLogo.description)
    let qrCode = LVGLImage(parent: screens[3], imageDescription: QRCode.description)

    pragmaLogo.addEventHandler(eventCallBack: handleEvent, filter: LV_EVENT_LONG_PRESSED)
    swiftLogo.addEventHandler(eventCallBack: handleEvent, filter: LV_EVENT_LONG_PRESSED)
    nelceaLogo.addEventHandler(eventCallBack: handleEvent, filter: LV_EVENT_LONG_PRESSED)
    qrCode.addEventHandler(eventCallBack: handleEvent, filter: LV_EVENT_LONG_PRESSED)
  }
}

var context = Context()

@_cdecl("thread0")
func thread0() {
  let ledStrip = LedStrip(strip: stripDevice, numPixels: STRIP_NUM_PIXELS)
  ledStrip.refresh()

  var ledLogic = LedStripLogic(ledStrip: ledStrip)

  while true {
    ledLogic.tick()
    k_msleep(20)
  }
}

@main
struct Main {
  static func main() {
    let lvgl = LVGL(device: display_dev)

    context.setupScreens()

    lvgl.taskHandler()
    lvgl.displayBlankingOff()

    var screenLogic = ScreenLogic()

    while true {
      screenLogic.tick()

      lvgl.taskHandler()

      k_msleep(10)
    }
  }
}

// ------------------------------------------------------------------

struct ScreenLogic {

  var screenTick = 0

  mutating func tick() {
    screenTick += 1
    if screenTick == 200 {
      // This takes a bit of time and stops the loop (so the LED pulsing) for a brief moment
      if context.screenRotation {
        context.currentScreen = (context.currentScreen + 1) % 3
      }
      screenTick = 0
    }
    if !context.screens[Int(context.currentScreen)].isActive {
      context.screens[Int(context.currentScreen)].setActive()
    }
  }
}

// MARK: LVGL

class LVGLScreen: LVGLObject, Equatable {
  static private var screens = [LVGLScreen]()

  init(pointer: UnsafeMutablePointer<lv_obj_t>? = lv_obj_create(nil)) {
    self.pointer = pointer
    Self.screens.append(self)
  }

  var pointer: UnsafeMutablePointer<lv_obj_t>?

  static func getActive() -> LVGLScreen? {
    let activeScreen = lv_scr_act()
    return Self.screens.first { $0.pointer == activeScreen }
  }

  static func == (lhs: LVGLScreen, rhs: LVGLScreen) -> Bool {
    lhs.pointer == rhs.pointer
  }

  var isActive: Bool {
    Self.getActive() == self
  }

  func setActive() {
    if let pointer {
      lv_disp_load_scr(pointer)
    }
  }

  deinit {
    Self.screens.removeAll { $0 == self }
  }
}
