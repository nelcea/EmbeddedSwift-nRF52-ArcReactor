struct LVGL {
  var device: UnsafePointer<device>

  init(device: UnsafePointer<device>) {
    if !device_is_ready(device) {
      fatalError("Device not ready, aborting test")
    }
    self.device = device
  }

  func taskHandler() {
    lv_task_handler()
  }

  func displayBlankingOff() {
    display_blanking_off(device)
  }
}

protocol LVGLObject {
  var pointer: UnsafeMutablePointer<lv_obj_t>? { get }
}

extension LVGLObject {
  func addEventHandler(
    eventCallBack: lv_event_cb_t, filter: lv_event_code_t, userData: UnsafeMutableRawPointer? = nil
  ) {
    lv_obj_add_event_cb(pointer!, eventCallBack, filter, userData)
  }
}

public enum LVGLAlignment: UInt8 {
  case `default` = 0
  case topLeft
  case topMid
  case topRight
  case bottomLeft
  case bottomMid
  case bottomRight
  case leftMid
  case rightMid
  case center
  case outTopLeft
  case outTopMid
  case outTopRight
  case outBottomLeft
  case outBottomMid
  case outBottomRight
  case outLeftTop
  case outLeftMid
  case outLeftBottom
  case outRightTop
  case outRightMid
  case outRightBottom
}

struct LVGLImage: LVGLObject {

  var imgDesc: UnsafeMutablePointer<lv_img_dsc_t>
  var pointer: UnsafeMutablePointer<lv_obj_t>?

  public init(
    parent: LVGLScreen? = nil,
    imageDescription: lv_img_dsc_t,
    alignment: LVGLAlignment = .center
  ) {
    guard let imgObj = lv_img_create(parent?.pointer) else {
      fatalError("Failed to create image")
    }
    self.pointer = imgObj
    imgDesc = UnsafeMutablePointer<lv_img_dsc_t>.allocate(capacity: 1)
    imgDesc.initialize(to: imageDescription)
    lv_img_set_src(imgObj, imgDesc)
    lv_obj_align(imgObj, alignment.rawValue, 0, 0)
  }

  func addEventHandler(
    eventCallBack: lv_event_cb_t, filter: lv_event_code_t, userData: UnsafeMutableRawPointer? = nil
  ) {
    lv_obj_add_event_cb(pointer!, eventCallBack, filter, userData)
    // TODO: image should not always be clickable, depends on the event
    lv_obj_add_flag(pointer!, UInt32(LV_OBJ_FLAG_CLICKABLE))
  }

  func hide() {
    lv_obj_add_flag(pointer!, UInt32(LV_OBJ_FLAG_HIDDEN))
  }

  func show() {
    lv_obj_clear_flag(pointer!, UInt32(LV_OBJ_FLAG_HIDDEN))
  }

}
