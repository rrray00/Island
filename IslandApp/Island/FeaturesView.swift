import PhotosUI
import SwiftUI
import UIKit

/// 功能① 取餐码 / 取件码：截图识别后上岛
struct CodeTabView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var recognizedCode: String = ""
    @State private var isRecognizing = false
    @State private var manualCode = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("从截图识别号码") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("选择截图", systemImage: "photo.on.rectangle")
                    }
                    if isRecognizing {
                        HStack {
                            ProgressView()
                            Text("识别中…")
                        }
                    }
                    if !recognizedCode.isEmpty {
                        LabeledContent("识别结果", value: recognizedCode)
                    }
                }

                Section("手动输入（兜底）") {
                    TextField("例如 A-238", text: $manualCode)
                }

                Section {
                    Button {
                        let code = recognizedCode.isEmpty ? manualCode : recognizedCode
                        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        LiveActivityManager.shared.start(
                            mode: .code,
                            title: "取餐码",
                            mainText: trimmed,
                            secondaryText: "锁屏随时可见"
                        )
                    } label: {
                        Label("上岛显示", systemImage: "iphone.dynamic.island")
                    }
                    .disabled(recognizedCode.isEmpty && manualCode.isEmpty)

                    Button("结束上岛") {
                        LiveActivityManager.shared.endCurrent()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("取餐码")
            .onChange(of: selectedItem) { _, item in
                guard let item else { return }
                Task {
                    isRecognizing = true
                    defer { isRecognizing = false }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let result = await CodeRecognizer.shared.recognizeCode(from: image) {
                        recognizedCode = result.code
                    }
                }
            }
        }
    }
}

/// 功能② 倒计时：上岛实时显示剩余时间，到点响铃震动提醒
struct TimerTabView: View {
    @State private var minutes: Int = 5
    @State private var running = false

    var body: some View {
        NavigationStack {
            Form {
                Section("时长") {
                    Stepper(value: $minutes, in: 1...120) {
                        Text("\(minutes) 分钟")
                    }
                }

                Section {
                    Button {
                        let end = Date().addingTimeInterval(TimeInterval(minutes * 60))
                        running = true
                        LiveActivityManager.shared.start(
                            mode: .timer,
                            title: "倒计时",
                            mainText: "进行中",
                            secondaryText: "\(minutes) 分钟后结束",
                            endDate: end
                        )
                        NotificationManager.shared.scheduleOnce(
                            identifier: "timer-end-\(Int(end.timeIntervalSince1970))",
                            title: "倒计时结束",
                            body: "\(minutes) 分钟的倒计时到啦",
                            at: end
                        )
                    } label: {
                        Label("开始倒计时并上岛", systemImage: "play.circle")
                    }
                    .disabled(running)

                    Button("停止") {
                        running = false
                        LiveActivityManager.shared.endCurrent()
                    }
                    .foregroundStyle(.red)
                    .disabled(!running)
                }
            }
            .navigationTitle("倒计时")
        }
    }
}

/// 功能③ 自定义文字：一句话常驻灵动岛
struct TextTabView: View {
    @State private var text = "记得喝水"

    var body: some View {
        NavigationStack {
            Form {
                Section("自定义文字") {
                    TextField("输入要显示在岛上的文字", text: $text)
                }

                Section {
                    Button {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        LiveActivityManager.shared.start(
                            mode: .text,
                            title: "自定义",
                            mainText: trimmed,
                            secondaryText: "长按可结束"
                        )
                    } label: {
                        Label("上岛显示", systemImage: "iphone.dynamic.island")
                    }

                    Button("结束上岛") {
                        LiveActivityManager.shared.endCurrent()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("自定义文字")
        }
    }
}

/// 功能④ 定时提醒：到点通知提醒，支持每天重复
struct ReminderTabView: View {
    @State private var reminderTitle = "喝水时间到"
    @State private var reminderTime = Date()
    @State private var repeatDaily = true
    @State private var scheduled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("提醒内容") {
                    TextField("提醒标题", text: $reminderTitle)
                    DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    Toggle("每天重复", isOn: $repeatDaily)
                }

                Section {
                    Button {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                        if repeatDaily {
                            NotificationManager.shared.scheduleDaily(
                                identifier: "daily-reminder",
                                title: reminderTitle,
                                body: "该做这件事啦",
                                hour: comps.hour ?? 9,
                                minute: comps.minute ?? 0
                            )
                        } else {
                            NotificationManager.shared.scheduleOnce(
                                identifier: "once-reminder",
                                title: reminderTitle,
                                body: "该做这件事啦",
                                at: reminderTime
                            )
                        }
                        scheduled = true

                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        LiveActivityManager.shared.start(
                            mode: .reminder,
                            title: "提醒",
                            mainText: reminderTitle,
                            secondaryText: formatter.string(from: reminderTime) + (repeatDaily ? " · 每天" : "")
                        )
                    } label: {
                        Label("设置提醒并上岛", systemImage: "bell.badge")
                    }

                    Button("取消提醒") {
                        NotificationManager.shared.cancel(identifier: "daily-reminder")
                        NotificationManager.shared.cancel(identifier: "once-reminder")
                        scheduled = false
                        LiveActivityManager.shared.endCurrent()
                    }
                    .foregroundStyle(.red)
                    .disabled(!scheduled)
                }
            }
            .navigationTitle("定时提醒")
        }
    }
}
