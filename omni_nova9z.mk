#
# Copyright (C) 2022 The Android Open Source Project
# Copyright (C) 2022 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# 云端 Action 编译安全版：不再依赖 vendor/omni/config/common.mk
# （云端 minimal-manifest-twrp 源码树里没有 OmniROM vendor，原版会报
#   "vendor/omni/config/common.mk" does not exist。改走与 twrp_nova9z.mk 相同的纯 AOSP 继承。）

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

# ── build.prop 来源说明（system 分区 build.prop）──────────────────────
# system 分区实为华为 SM6350 平台「通用 ODM 镜像」generic_a9_odm，并非 TRG-AN00 专属：
#   ro.system.build.fingerprint = Huawei/generic_a9_odm/generic_a9_odm:11/RP1A.200720.011/root202210121554:user/dev-keys
#   ro.product.system.device    = generic_a9_odm
# 机型 TRG-AN00 / Hi nova 9z 的差异化信息落在 odm/vendor/product 分区，不在 system build.prop。
# 故下方 fingerprint 采用「真实版本号(RP1A.200720.011 / 11) + 真实设备标识(TRG-AN00)」组合。
# 完整原始文件见 build.prop_reference/system_build.prop
BUILD_FINGERPRINT := Huawei/TRG-AN00/TRG-AN00:11/RP1A.200720.011/root202210121554:user/release-keys

# 真实版本属性说明：ro.* 带点的属性不能放进 PRODUCT_BUILD_PROP_OVERRIDES（见 twrp_nova9z.mk 注释），
# 改放 system.prop。
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="TRG-AN00-user 11 RP1A.200720.011 release-keys"

# TWRP 标志（与 BoardConfig 中 TW_* 同步，保证任意 makefile 名都能编出可用 TWRP）
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := false
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_INCLUDE_CRYPTO := false  # nova9z 无对应 crypto/keymaster 后端，编进来会在 Decrypt_FBE_DE 硬 abort（v9 崩溃循环根因）；关掉让 /data 被干净跳过
TW_INCLUDE_FASTBOOTD := true
