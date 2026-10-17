#
# Copyright (C) 2022 The Android Open Source Project
# Copyright (C) 2022 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/huawei/nova9z

# A/B（本机为非 A/B，故无 A/B 相关条目）

# ── 修复：补 recovery ramdisk 根 /init.rc 入口 ──────────────────────────
# 你用的 TWRP 源码树只发了 init.recovery.*.rc 片段、没发入口 /init.rc，
# 导致 recovery 服务成孤儿、灰屏黑屏循环。这里把本设备树的
# recovery/root/init.rc 直接覆盖到 recovery ramdisk 根，重新编译即生效。
# （独立 recovery 分区机型必须自带根 init.rc；recovery-as-boot/A-B 机型
#   才由 boot 镜像的 init 提供入口。）
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.rc:$(TARGET_RECOVERY_ROOT_OUT)/init.rc

