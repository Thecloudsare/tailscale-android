# Tailscale Android 客户端

<https://tailscale.com>

基于 WireGuard® 的私有网络，轻松组建安全互联。

---

## 概述

本仓库包含 Tailscale Android 客户端的开源代码，已对构建流程进行简化与修复，使用标准 Go 1.24+ 和 NDK 26+，不再依赖定制 Go 编译器。

---

## 下载使用

#### Tailscale 官方 APK

最新稳定版 APK 可从 [Tailscale Packages 稳定版渠道](https://pkgs.tailscale.com/stable/#android) 获取。

不稳定版 APK 可从 [Tailscale Packages 不稳定版渠道](https://pkgs.tailscale.com/unstable/#android) 获取。

这些 APK 包含所有支持的平台和架构。如需安装紧凑版 APK、Android TV 版，或希望获得自动更新，请访问 [Google Play 商店](https://play.google.com/store/apps/details?id=com.tailscale.ipn)。

#### Google Play 商店

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=com.tailscale.ipn)

在正式发布之前帮助测试新功能和错误修复！[测试版通道](https://play.google.com/apps/testing/com.tailscale.ipn) 已在 Play 商店开放。

#### Amazon Appstore

该应用可从 [Amazon Appstore](https://www.amazon.com/dp/B0D38TRB3N) 下载，适用于 Amazon Fire 平板和 Fire TV 设备。

#### F-Droid

[F-Droid](https://f-droid.org/packages/com.tailscale.ipn/) 项目从本仓库构建源代码并维护独立构建的 APK。注意：F-Droid 构建不由 Tailscale 团队发布、更新或验证。

---

## 构建环境准备

构建环境可通过 Android Studio 或 Docker/Nix 方式搭建。

### 通用要求

- Go 运行时（**1.24+**）
- Android SDK
- Android SDK 组件（执行 `make androidsdk` 可自动安装）
- Android NDK **26.3.11579264 或更新版本**

### Android Studio（推荐开发方式）

1. 安装 Go 运行时（<https://go.dev/dl/>）
2. 安装 Android Studio（<https://developer.android.com/studio>）
3. 启动 Android Studio，从欢迎界面选择 "More Actions" -> "SDK Manager"
4. 在 SDK Manager 中选择 "SDK Tools" 选项卡，安装 "Android SDK Command-line Tools (latest)"
5. 执行 `make androidsdk` 安装必要的 SDK 组件

如果不使用 Android Studio，也可独立安装 Android SDK。Makefile 会自动检测常见路径，Debian/Ubuntu 系统上执行 `sudo apt install android-sdk` 即可。若 SDK 安装在非标准位置，请设置 `ANDROID_SDK_ROOT` 环境变量指向 SDK 路径。

执行 `make androidpath` 可获取正确的工具路径并添加到 shell 中。

#### 代码格式

项目使用 ktfmt 插件（默认设置）自动格式化所有 Java、Kotlin 和 XML 文件。建议在 Android Studio 中启用 "Format on Save"。

### Docker

如不希望污染主机系统，可使用 Docker 开发环境：

```sh
make docker-shell
