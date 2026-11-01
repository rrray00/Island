# Island — 你的"上岛记"（灵动岛工具 App）

把取餐码 / 取件码、倒计时、自定义文字、定时提醒显示在 iPhone 灵动岛和锁屏上。
纯本地运行，不联网、不上传任何数据。

## 功能

| 功能 | 说明 |
|---|---|
| 🔢 取餐码/取件码 | 从截图识别号码（离线识别），一键上岛 |
| ⏱ 倒计时 | 自定义时长（1–120 分钟），灵动岛实时显示剩余，到点响铃震动 |
| ✍️ 自定义文字 | 一句话常驻灵动岛，随时可改 |
| 🔔 定时提醒 | 设定时间到点提醒，支持每天重复 |

## 工程结构

```
IslandApp/
├── project.yml                    # XcodeGen 工程定义（自动生成 .xcodeproj）
├── .github/workflows/build.yml    # GitHub Actions 云编译配置（免 Mac 编译）
├── Shared/                        # App 与 Widget 共享的灵动岛数据模型
├── Island/                        # 主 App
│   ├── IslandApp.swift
│   ├── ContentView.swift          # 四个功能页
│   ├── FeaturesView.swift
│   ├── LiveActivityManager.swift  # 启动/更新/结束灵动岛
│   ├── CodeRecognizer.swift       # Vision 离线识别
│   ├── NotificationManager.swift  # 本地通知
│   └── Assets.xcassets            # 图标（1024×1024 已放好）
└── IslandWidget/                  # 灵动岛 + 锁屏界面（Live Activity）
```

## 免 Mac 安装流程（路线 A：GitHub 云编译 + Sideloadly 签名）

> 原理：GitHub 的 macOS 云服务器替你完成编译（不需要你懂代码），产出未签名 .ipa；
> 你在 Windows 上用 Sideloadly 用自己的 Apple ID 免费签名并装进 iPhone。
> 免费签名 7 天有效，到期用 Sideloadly 重新装一次即可。

### 第 1 步：上传工程到 GitHub

1. 注册/登录 [GitHub](https://github.com)（免费）；
2. 右上角 **+** → **New repository** → 名称填 `Island`（公开/私有都行）→ Create；
3. 把本 `IslandApp` 文件夹里的**所有内容**上传到这个仓库（网页上点 "uploading an existing file"，把整个文件夹拖进去即可），提交。

### 第 2 步：云端编译

1. 打开你的仓库 → **Actions** 标签页；
2. 第一次会提示 "I understand my workflows, go ahead and enable them"，点一下开启；
3. 左侧选 **Build Island IPA** → 右侧 **Run workflow** → 绿色按钮确认；
4. 等约 5–10 分钟，构建成功后 Actions 页面会出现本次运行记录，点进去 → 底部 **Artifacts** → 下载 `Island-unsigned-ipa`（zip）。

### 第 3 步：签名安装到 iPhone

1. Windows 电脑下载 [Sideloadly](https://sideloadly.io/)（免费）并安装；
2. 手机用数据线连电脑，解锁后点"信任此电脑"；
3. 电脑装好 [iTunes](https://www.apple.com/itunes/) 或 Apple Devices（Windows 商店版）；
4. 打开 Sideloadly：把下载解压出的 `Island-unsigned.ipa` 拖进去，输入你的 Apple ID 和**App 专用密码**（Apple ID 网页 → 登录与安全 → App 专用密码 生成一个），点 **Start**；
5. 手机上：设置 → 通用 → VPN与设备管理 → 信任你的 Apple ID；
6. 打开 Island App → 允许通知 → 开始"上岛"。

### 第 4 步（7 天后）：重新签名

- 免费签名 7 天到期后 App 打不开，重新执行第 3 步（连接电脑 → Sideloadly → 重装）即可，5 分钟搞定。

## 想长期使用 / 上架？

- 免费签名限制（7 天、每年最多 3 台设备）只影响"个人自用"；
- 购买 Apple 开发者账号（¥688/年）后，可以在 Xcode 里去掉签名限制，并通过 TestFlight 分享给朋友或上架 App Store，代码不需要改动。

## 常见问题

**Q：灵动岛上没显示？**
A：确认手机是 iPhone 14 Pro 及以上机型；打开"设置 → 通知 → Island → 允许通知"，并打开"实时活动"；另外同一时间只支持一个活动（新功能会顶掉旧的）。

**Q：识别不出号码？**
A：选择清晰的截图，号码尽量大；识别结果可以手动改。也可以直接用"手动输入"。

**Q：倒计时锁屏不更新秒数？**
A：系统限制灵动岛约每分钟刷新一次，分钟级足够日常使用；锁屏展开后可看到剩余时长。

**Q：编译报错？**
A：最常见是 Actions 里 workflow 没启用，或仓库没包含 `.github/workflows/build.yml`。上传时确认隐藏文件（.github 文件夹）也上传了。
