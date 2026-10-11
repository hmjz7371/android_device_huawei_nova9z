#
# Copyright (C) 2022 The Android Open Source Project
# Copyright (C) 2022 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
# 走纯 TWRP 体系（不依赖 vendor/omni/），用于云端 Action 编译
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Inherit from nova9z device
$(call inherit-product, device/huawei/nova9z/device.mk)

PRODUCT_DEVICE := nova9z
PRODUCT_NAME := twrp_nova9z
PRODUCT_BRAND := Huawei
PRODUCT_MODEL := Hi nova 9z
PRODUCT_MANUFACTURER := huawei

# 同 omni 版本：真实版本号 + 设备标识的合成 fingerprint
BUILD_FINGERPRINT := Huawei/TRG-AN00/TRG-AN00:11/RP1A.200720.011/root202210121554:user/release-keys

# 真实版本属性（提取自 system build.prop，已确证）
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="TRG-AN00-user 11 RP1A.200720.011 release-keys" \

# TWRP 标志（与 BoardConfig 中 TW_* 同步）
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_FASTBOOTD := true
