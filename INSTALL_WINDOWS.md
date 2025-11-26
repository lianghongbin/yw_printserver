# Windows 安装和配置指南

本指南将帮助您在 Windows 系统上安装打印服务器并配置开机自启动。

## 前置要求

1. **Windows 7 或更高版本**
2. **管理员权限**（用于安装和配置）
3. **已构建的可执行文件**（`dist\print_server.exe`）

## 快速安装

### 步骤 1: 构建可执行文件

在项目目录中打开命令提示符（CMD）或 PowerShell，运行：

```cmd
build_windows.bat
```

构建完成后，会在 `dist` 目录下生成 `print_server.exe`。

### 步骤 2: 安装服务

1. **右键点击** `install_windows.bat`
2. 选择 **"以管理员身份运行"**
3. 按照提示完成安装

安装程序会：
- 将可执行文件复制到 `C:\Program Files\PrintServer\`
- 创建开机自启动任务
- 创建卸载脚本

### 步骤 3: 验证安装

安装完成后，服务会在下次登录时自动启动。要立即启动服务：

1. 打开文件资源管理器
2. 导航到 `C:\Program Files\PrintServer\`
3. 双击 `print_server.exe`

或者从命令行运行：

```cmd
"C:\Program Files\PrintServer\print_server.exe"
```

## 配置开机自启动

### 方法 1: 使用安装脚本（推荐）

运行 `install_windows.bat` 会自动配置开机自启动。

### 方法 2: 手动配置

如果安装时自启动配置失败，可以单独运行：

```cmd
# 以管理员身份运行
setup_autostart.bat
```

### 方法 3: 使用任务计划程序（手动）

1. 按 `Win + R`，输入 `taskschd.msc`，回车
2. 点击右侧 **"创建基本任务"**
3. 任务名称：`PrintServer`
4. 触发器：**"当计算机启动时"** 或 **"当用户登录时"**
5. 操作：**"启动程序"**
6. 程序或脚本：`C:\Program Files\PrintServer\print_server.exe`
7. 完成创建

### 方法 4: 使用启动文件夹（简单但不推荐）

1. 按 `Win + R`，输入 `shell:startup`，回车
2. 创建快捷方式指向：`C:\Program Files\PrintServer\print_server.exe`

**注意**：此方法会在用户登录时启动，而不是系统启动时。

## 卸载服务

### 方法 1: 使用卸载脚本

1. 导航到 `C:\Program Files\PrintServer\`
2. **右键点击** `uninstall.bat`
3. 选择 **"以管理员身份运行"**

### 方法 2: 手动卸载

1. **停止服务**：
   ```cmd
   taskkill /F /IM print_server.exe
   ```

2. **删除开机自启动任务**：
   ```cmd
   schtasks /delete /tn "PrintServer" /f
   ```

3. **删除安装目录**：
   ```cmd
   rd /s /q "C:\Program Files\PrintServer"
   ```

## 服务管理

### 查看服务状态

```cmd
tasklist | findstr print_server.exe
```

### 停止服务

```cmd
taskkill /F /IM print_server.exe
```

### 启动服务

```cmd
"C:\Program Files\PrintServer\print_server.exe"
```

### 查看任务计划程序任务

```cmd
schtasks /query /tn "PrintServer"
```

## 故障排除

### 问题 1: "需要管理员权限"

**解决方案**：右键点击脚本，选择"以管理员身份运行"

### 问题 2: 服务无法启动

**检查项**：
- 端口 8023 是否被占用
- 防火墙是否阻止了端口
- 查看控制台输出的错误信息

### 问题 3: 开机自启动不工作

**解决方案**：
1. 检查任务计划程序中是否存在 `PrintServer` 任务
2. 检查任务是否已启用
3. 查看任务历史记录中的错误信息
4. 尝试手动运行 `setup_autostart.bat`

### 问题 4: 端口被占用

**解决方案**：
```cmd
# 查看占用端口的进程
netstat -ano | findstr :8023

# 结束进程（替换 PID 为实际进程ID）
taskkill /F /PID <PID>
```

### 问题 5: 防火墙阻止连接

**解决方案**：
1. 打开 Windows 防火墙设置
2. 添加入站规则，允许端口 8023
3. 或者临时关闭防火墙测试

## 文件结构

安装后的目录结构：

```
C:\Program Files\PrintServer\
├── print_server.exe      # 主程序
├── start_server.bat       # 启动脚本
└── uninstall.bat         # 卸载脚本
```

## 日志

服务日志会输出到控制台窗口。如果需要将日志保存到文件，可以修改启动方式：

```cmd
"C:\Program Files\PrintServer\print_server.exe" > "C:\Program Files\PrintServer\log.txt" 2>&1
```

## 高级配置

### 修改安装目录

编辑 `install_windows.bat`，修改 `INSTALL_DIR` 变量：

```batch
set "INSTALL_DIR=D:\MyApps\PrintServer"
```

### 修改端口

编辑 `print_server.py` 中的 `LISTEN_PORT` 变量，然后重新构建。

### 添加更多打印机

编辑 `print_server.py` 中的 `PRINTER_MAP` 字典，然后重新构建。

## 技术支持

如遇到问题，请检查：
1. Windows 事件查看器中的应用程序日志
2. 任务计划程序中的任务历史记录
3. 控制台输出的错误信息

## 注意事项

- 服务需要网络访问权限（用于接收 PDA 请求和连接打印机）
- 建议将服务添加到防火墙例外列表
- 定期检查服务是否正常运行
- 建议配置日志文件以便排查问题


