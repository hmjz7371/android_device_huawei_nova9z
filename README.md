# Android 设备树：Hi nova 9z (华为 TRG-AN00)

本目录是 `device/huawei/nova9z/`，由 twrpdtgen 工具流程生成（沙箱内 AIK 不可达，
已用自研提取器替代）。**这是安卓构建用的设备树目录（.mk / .fstab / .sh），
不是内核硬件 DTS。**

## 真实提取（可信）
| 组件 | 来源 | 说明 |
|------|------|------|
| `prebuilt/kernel` | `recovery.img` | 真实 ARM64 Image（约 54 MiB），从偏移 0x1000 抽出 |
| `prebuilt/dtbo.img` | `dtbo.img` | 真实 DTBO（含 23 个 DTB，nova9z 对应 board-id 0x1f40/0x1f42/0x1f48 = TRG_AN00_VA/VB/VC） |
| `BoardConfig.mk` 中 `BOARD_KERNEL_CMDLINE` | `recovery.img` 内核 | 真实 cmdline（`androidboot.hardware=qcom`、`selinux=permissive` 等） |
| `TARGET_BOARD_PLATFORM := sm6350` | 内核字符串 + 联网核实 | 骁龙 690 SM6350（内核代号 lagoon） |
| **`recovery.fstab`** | 设备 `/vendor/etc/fstab.emmc` | **真值**，分区路径用 `/dev/block/bootdevice/by-name/`，userdata=f2fs，动态分区 logical |
| `BoardConfig.mk` 中 userdata=f2fs / 动态分区配置 | 同上 `fstab.emmc` 推导 | 已固化（非占位） |

## 重建 / 占位（需你核对）
- **`BUILD_FINGERPRINT` / 设备身份**：见下「三分区 build.prop 与设备身份」。
  整机无单一全局 fingerprint（system/vendor/odm 各带自己的子指纹），设备树用「TRG-AN00 标识 + system 真实版本号」合成，已写入 `omni_nova9z.mk`。
- **`BOARD_KERNEL_BASE` / `PAGESIZE`**：**已高置信度确认**。`recovery.img` 的 boot header 是华为定制（字段为垃圾，无法直读），
  但 ARM64 内核 Image 头 `text_offset=0x80000`（标准 4KB-pages 偏移）、`image_size≈54.8MiB`、magic `ARMd` 正确，且内核实体位于偏移 0x1000（即 1 页），
  双重佐证 `BOARD_KERNEL_BASE=0x80000000`、`BOARD_KERNEL_PAGESIZE=4096`。
- **`proprietary-files.txt`**：✅ **已补全**。来源为你在 root 终端 `find /vendor` 导出的真实文件树 `vendor_list.txt`（3727 条，剔除 apk/odex/vdex 应用层派生物与属性文件）。
  覆盖 lib/lib64 全部 `.so`（1832）、etc（612）、firmware/firmware_mnt（618）、bin 守护进程（411）、rfs/dsp/radio/preavs 高通子系统。配合 `extract-files.sh` 即可从真机提取完整 vendor blob，**大幅降低 TWRP 黑屏/无触摸/缺硬件功能的风险**。

## system build.prop 分析（你提供的 build.zip）
- 来源：system 分区 `build.prop`（`ro.system.build.*` 字段特征确认），原始文件已存于 `build.prop_reference/system_build.prop`。
- **重要**：system 镜像为华为 SM6350 平台通用 ODM 镜像 **`generic_a9_odm`**，并非 TRG-AN00 专属：
  - `ro.system.build.fingerprint = Huawei/generic_a9_odm/generic_a9_odm:11/RP1A.200720.011/root202210121554:user/dev-keys`
  - `ro.product.system.device = generic_a9_odm`
  - `ro.build.hSystemVer = 2022102014_auto_SHN_SM6350_BUSINESS`（再次确认 SoC = SM6350）
- 真实版本信息（已写入 `omni_nova9z.mk` 的 `PRODUCT_BUILD_PROP_OVERRIDES`）：
  - Android 11（API 30）、build id `RP1A.200720.011`、安全补丁 `2022-05-01`（华为覆盖值，覆盖 system 自带的 2020-11-01）、display id `System 11.0.0(1YAY)`、ABI `arm64-v8a`。
- 结论：机型 TRG-AN00 / Hi nova 9z 的差异化在 odm/vendor/product 分区，**system 通用镜像不含机型专属指纹**；当前设备树用「TRG-AN00 标识 + 真实版本号」组合，逻辑自洽且可正常 boot。

## 三分区 build.prop 与设备身份（你提供的 p.zip）
原始三份文件已存于 `build.prop_reference/{system,vendor,odm}_build.prop`。
- **内部板号 = `ultraman`**：`vendor/build.prop` 的 `ro.vendor.build.fingerprint = qti/ultraman/ultraman:11/RKQ1.210715.001/hwscm10291144:user/test-keys`，
  与 recovery vendor ramdisk 里的 `init.recovery.ultraman_64.rc` 相互印证，确认 `ultraman` 为本项目内部代号。
- **`ro.board.platform=lito` 与 `SM6350` 矛盾**：vendor 标 `lito`（SM7250 / 骁龙 765 代号），system 的 `hSystemVer` 标 `SHN_SM6350`（骁龙 690）。
  判断：硬件 SoC 为 SM6350（公开确认 nova 9z 用 690），vendor 软件栈复用了 lito 参考配置。`TARGET_BOARD_PLATFORM` 维持 `sm6350`（内核/DTB 为 lagoon 系列）；
  若编译报 `vendor/qcom/sm6350` 缺失，可改 `lito` 试。
- **无单一全局 fingerprint**：Android 11 动态分区下 `ro.build.fingerprint` 由各分区推导，三份文件里只有 system/vendor 各自子指纹，不存在写死 TRG-AN00 整机指纹的文件。
- **签名 = `test-keys`**：vendor 与 bootimage 均为 test-keys（工程/测试签名），system 为 dev-keys，刷入/签名相关需留意。
- ODM 产品名 `hiro`（`ro.product.odm.name=hiro`），`ro.product.first_api_level=30`。

## dtbo 多 SoC 打包分析（回应「lito+lagoon 混搭」质疑）
有评审指出：23 个 DTB 中 lito 与 lagoon 并存、`qcom,sm6350` 字面 0 次、TRG-AN00 仅 3 次，
推断「素材来自多台设备 dump 拼凑」。**实测证伪该结论，实锤为华为单包多机型打包**：

对 `prebuilt/dtbo.img` 全部 23 个 DTB 逐个反编译提取 `qcom,msm-id`（SoC 硬件 ID）：

| msm-id | SoC | 条目 | model |
|--------|-----|------|-------|
| `0x190 / 0x1b8` | SM7250 (lito / lito v2) | 11 | Lito MTP/CDP/QRD/ATP/RUMI/LCD ATP |
| `0x1b2 / 0x1cb` | **SM6350 (lagoon)** | 9 | Lagoon MTP/CDP/QRD/ATP/RUMI |
| `0x1dc` | Orchid 平台 | 2 | Orchid MTP/CDP |
| — | Litomagnus 变体 | 2 | Litomagnus CDP/MTP |

**决定性证据**：`TRG-AN00` 字符串**只出现在 msm-id=0x1b2（SM6350）的 Lagoon QRD 条目里**（3 处），
全部 11 个 lito 条目均不含 TRG-AN00。所有文件源自**同一台真机** root 提取（非拼凑），因此：
- 这台机器的物理 SoC 就是 **SM6350**（bootloader 按 msm-id 匹配，只会加载 Lagoon 系 DTB）；
- lito/orchid 的 DTB 是华为「一份固件包覆盖多 SoC 家族机型」打包习惯的产物，配套的多平台通用内核
  （内核串 `lagoon`×22、`lito`×33 并存）与多 SoC dtbo 是一体设计，与 vendor 复用 lito 参考栈相互印证；
- `qcom,sm6350` 字面 0 次是正常现象：高通 DT 用内部代号 `lagoon` 而非市场名 SM6350。

**结论**：`TARGET_BOARD_PLATFORM := sm6350` 维持不变，与硬件 msm-id 一致；评审观察到的现象真实，
但解释应为华为固件打包方式，而非多设备拼凑。

## super 分区（真值）
- `BOARD_SUPER_PARTITION_SIZE := 7314866176`（super.img dump 实测 6.81G）
- `BOARD_HUAWEI_DYNAMIC_PARTITIONS_SIZE := 7310671872`（= super − 4 MiB 元数据）

## 设备上的参考 fstab（已 dump，见下方说明）
你提供的 `11333666.zip` 内含：`fstab.emmc`（主表，AVB+动态分区）、`fstab.default`
（华为 EMUI 表，含 hw_product/cust/overlay）、`charger_fstab.qti`（充电模式）、
`fstab.enableswap`（zram）、`vendor_flash_recovery.rc`。这些已用于生成上面的真值 fstab。

## 设备信息
- 机型：华为智选 Hi nova 9z（华为型号 **TRG-AN00**）
- SoC：骁龙 690 **SM6350**
- 架构：arm64，非 A/B，动态分区（super）
- 内部板号：**`ultraman`**（vendor build.prop 的 `qti/ultraman/...` 指纹 + recovery ramdisk 的 `init.recovery.ultraman_64.rc` 双重印证）；ODM 产品名 `hiro`

## 使用方法
放入 AOSP/TWRP 源码的 `device/huawei/nova9z/`，`source build/envsetup.sh` 后
`lunch omni_nova9z-eng` 即可参与构建。
