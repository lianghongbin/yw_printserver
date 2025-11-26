# Windows 快速安装指南

## 前置要求

### 情况 A: 需要自己构建可执行文件

如果您需要从源代码构建，需要：
- **Python 3.8 或更高版本**（[下载地址](https://www.python.org/downloads/)）
- 安装时请勾选 "Add Python to PATH"

### 情况 B: 已有构建好的可执行文件

如果您已经有 `dist\print_server.exe` 文件，**不需要安装 Python**，可以直接跳到步骤 2 进行安装。

## 安装步骤

### 1. 构建可执行文件（如果需要）

如果您还没有 `dist\print_server.exe`，需要先构建：

双击运行 `build_windows.bat`，或在命令行中执行：

```cmd
build_windows.bat
```

**注意**：构建过程需要 Python 环境，但构建完成后生成的 `print_server.exe` 是独立可执行文件，**运行时不需 Python**。

构建完成后，会在 `dist` 目录生成 `print_server.exe`。

### 2. 安装服务（以管理员身份运行）

1. **右键点击** `install_windows.bat`
2. 选择 **"以管理员身份运行"**
3. 等待安装完成

服务将安装到 `C:\Program Files\PrintServer\`，并自动配置开机自启动。

### 3. 启动服务

安装后，服务会在下次登录时自动启动。要立即启动：

```cmd
"C:\Program Files\PrintServer\print_server.exe"
```

## 卸载

1. 导航到 `C:\Program Files\PrintServer\`
2. **右键点击** `uninstall.bat`
3. 选择 **"以管理员身份运行"**

## 常见问题

### Q: 运行 print_server.exe 需要安装 Python 吗？

**A: 不需要**。`print_server.exe` 是独立的可执行文件，已经包含了所有依赖，可以直接运行，无需安装 Python。

### Q: 什么时候需要 Python？

**A: 只在构建阶段需要**。如果您需要从源代码构建 `print_server.exe`，才需要安装 Python。如果已经有构建好的 exe 文件，就不需要 Python。

### Q: 如何检查是否已安装 Python？

在命令行中运行：
```cmd
python --version
```

如果显示版本号（如 `Python 3.11.0`），说明已安装。

## 查看详细文档

更多信息请查看 [INSTALL_WINDOWS.md](INSTALL_WINDOWS.md)

