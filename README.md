# Tailscale Android 客户端

Tailscale 是一款基于 WireGuard® 协议的私有网络（VPN）工具，可帮助您轻松、安全地连接所有设备。本仓库包含 Tailscale Android 客户端的开源代码。

项目主页：[https://tailscale.com](https://tailscale.com)

---

## 概述

本仓库提供了 Tailscale Android 客户端的完整源代码，支持通过多种方式构建和安装。

---

## 获取官方版本

如果您不想自行编译，可通过以下渠道获取官方构建的 APK：

- **Google Play**：[点击安装](https://play.google.com/store/apps/details?id=com.tailscale.ipn)
- **Beta 测试版**：[Play Store 测试通道](https://play.google.com/apps/testing/com.tailscale.ipn)
- **Amazon Appstore**（适用于 Fire 平板和 Fire TV 设备）：[点击下载](https://www.amazon.com/dp/B0D38TRB3N)
- **F-Droid**：[F-Droid 仓库](https://f-droid.org/packages/com.tailscale.ipn/)

> **注意**：F-Droid 版本由社区构建，Tailscale 团队不负责其发布、更新或验证。

---

## 构建环境准备

构建本应用需要以下环境：

- Go 运行时（[下载地址](https://go.dev/dl/)）
- Android SDK
- Android SDK 组件（执行 `make androidsdk` 可自动安装）

### 方式一：Android Studio（推荐用于长期开发）

1. 安装 Go 运行时（[https://go.dev/dl/](https://go.dev/dl/)）。
2. 安装 Android Studio（[https://developer.android.com/studio](https://developer.android.com/studio)）。
3. 启动 Android Studio，在欢迎界面选择 **“More Actions”** → **“SDK Manager”**。
4. 在 **“SDK Tools”** 选项卡中，安装 **“Android SDK Command-line Tools (latest)”**。
5. 在项目根目录执行以下命令，安装必要的 SDK 组件：
    
    make androidsdk

**非标准路径配置**：若 Android SDK 安装在非默认路径，请设置环境变量 `ANDROID_SDK_ROOT` 指向 SDK 目录。若已安装 Android Studio 但工具链不在 PATH 中，可执行 `make androidpath` 获取正确路径并导出。

**代码格式化**：项目使用 ktfmt 插件进行代码格式化（默认配置）。建议在 Android Studio 中启用 **“Format on Save”** 功能，以自动格式化 Java、Kotlin 和 XML 文件。

### 方式二：Docker（适用于隔离环境）

若希望避免在宿主机安装依赖，可使用 Docker 开发环境：

    make docker-shell

其他 Docker 相关构建命令请参考 Makefile。Docker 镜像名称可在 Makefile 中自定义，修改后需重建缓存镜像。

### 方式三：Nix（适用于 Nix 用户）

若已安装 Nix 2.4 或更高版本，可使用以下命令进入开发环境：

    alias nix='nix --extra-experimental-features "nix-command flakes"'
    nix develop

---

## 构建 APK

在项目根目录执行以下命令：

    make apk          # 构建 APK
    make install      # 安装到已连接的 Android 设备

---

## 发布版本

执行以下命令可自动更新版本号并打标签：

    make tag_release

该命令会：
- 增加 Android 版本代码（versionCode）
- 更新版本名称（versionName）
- 为当前提交创建 Git 标签

---

## 技术说明

- **Go 版本要求**：项目仅保证支持最新的 Go 稳定版及 Go 测试版/候选版（当前为 Go 1.x）。早期 Go 版本或 GOPATH 模式可能无法正常工作，官方不提供支持。
- **Fire TV 开发**：在 Fire TV 设备上调试时，需在设备端开启 ADB 调试（路径：Settings → My Fire TV → Developer Options → ADB Debugging → ON）。常用 ADB 命令请参考官方文档。

---

## 许可证

本项目基于 BSD 协议开源，详见 [LICENSE](LICENSE) 文件。

---

## 贡献指南

欢迎提交 Issue 和 Pull Request。提交代码前请确保：
- 代码已通过 `ktfmt` 格式化
- 所有测试用例通过
- 提交信息清晰描述变更内容
