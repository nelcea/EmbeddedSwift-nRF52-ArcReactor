//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#include <autoconf.h>

#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/led_strip.h>
#include <zephyr/drivers/display.h>
#include <lvgl.h>

#define STRIP_NODE		DT_ALIAS(led_strip)
#define STRIP_NUM_PIXELS	 24 // TODO: DT_PROP(DT_ALIAS(led_strip), chain_length)
static const struct device *const stripDevice = DEVICE_DT_GET(STRIP_NODE);

static const struct device *display_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_display));

extern const lv_img_dsc_t hovercode;
extern const lv_img_dsc_t logo;
extern const lv_img_dsc_t NelceaLogo;
extern const lv_img_dsc_t PragmaLogo;
