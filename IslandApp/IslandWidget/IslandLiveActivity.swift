import ActivityKit
import SwiftUI
import WidgetKit

/// 灵动岛 + 锁屏界面
struct IslandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IslandActivityAttributes.self) { context in
            // 锁屏界面
            LockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.75))
                .activitySystemActionTint(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开状态（长按）
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: context.state.mode == .timer ? "timer" : "iphone")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.center) {
                    if context.state.mode == .timer, let end = context.state.endDate {
                        Text(timerInterval: Date.now...end)
                            .font(.system(.title2, design: .monospaced))
                            .foregroundStyle(.white)
                    } else {
                        Text(context.state.mainText)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.secondaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } compactLeading: {
                Text(context.state.mainText.prefix(4))
                    .font(.caption2)
                    .foregroundStyle(.white)
            } compactTrailing: {
                Image(systemName: context.state.mode == .timer ? "timer" : "iphone")
                    .foregroundStyle(.white)
            } minimal: {
                Text(context.state.mode == .timer ? "⏱" : "🅸")
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
        }
    }
}

/// 锁屏长条界面
private struct LockScreenView: View {
    let context: ActivityViewContext<IslandActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(context.attributes.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if context.state.mode == .timer, let end = context.state.endDate {
                    Text(timerInterval: Date.now...end)
                        .font(.system(.body, design: .monospaced).bold())
                        .foregroundStyle(.white)
                }
            }
            Text(context.state.mainText)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
            if !context.state.secondaryText.isEmpty {
                Text(context.state.secondaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
    }
}
