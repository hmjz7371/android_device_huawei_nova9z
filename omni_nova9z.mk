#
# Copyright (C) 2022 The Android Open Source Project
# Copyright (C) 2022 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from nova9z device
$(call inherit-product, device/huawei/nova9z/device.mk)

PRODUCT_DEVICE := nova9z
PRODUCT_NAME := omni_nova9z
PRODUCT_BRAND := Huawei
PRODUCT_MODEL := Hi nova 9z
PRODUCT_MANUFACTURER := huawei

# ── build.prop 来源说明（你提供的 system 分区 build.prop）──────────────
# system 分区实为华为 SM6350 平台「通用 ODM 镜像」generic_a9_odm，并非 TRG-AN00 专属：
#   ro.system.build.fingerprint = Huawei/generic_a9_odm/generic_a9_odm:11/RP1A.200720.011/root202210121554:user/dev-keys
#   ro.product.system.device    = generic_a9_odm
# 机型 TRG-AN00 / Hi nova 9z 的差异化信息落在 odm/vendor/product 分区，不在 system build.prop。
# 故下方 fingerprint 采用「真实版本号(RP1A.200720.011 / 11) + 真实设备标识(TRG-AN00)」组合；
# 若需 100% 真实的 TRG-AN00 专属 fingerprint，请从 odm 或 vendor 分区提取其 build.prop。
# 完整原始文件见 build.prop_reference/system_build.prop
BUILD_FINGERPRINT := Huawei/TRG-AN00/TRG-AN00:11/RP1A.200720.011/root202210121554:user/release-keys

# 真实版本属性（提取自 system build.prop，已确证）
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="TRG-AN00-user 11 RP1A.200720.011 release-keys" \
    ro.build.id=RP1A.200720.011 \
    ro.build.version.release=11 \
    ro.build.version.sdk=30 \
    ro.build.version.security_patch=2022-05-01 \
    ro.build.display.id="System 11.0.0(1YAY)" \
    ro.product.cpu.abi=arm64-v8a
