import ActivityKit
import Foundation

/// 负责启动 / 更新 / 结束灵动岛实时活动
@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published var currentActivity: Activity<IslandActivityAttributes>?

    private init() {}

    /// 是否支持实时活动
    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    /// 开始一个实时活动（自动先结束旧的）
    @discardableResult
    func start(
        mode: IslandMode,
        title: String,
        mainText: String,
        secondaryText: String = "",
        endDate: Date? = nil
    ) -> Activity<IslandActivityAttributes>? {
        // 同一时间只保留一个活动
        endCurrent()

        guard isSupported else { return nil }

        let state = IslandActivityAttributes.ContentState(
            mode: mode,
            mainText: mainText,
            secondaryText: secondaryText,
            endDate: endDate
        )
        let attributes = IslandActivityAttributes(title: title)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            currentActivity = activity
            return activity
        } catch {
            print("启动实时活动失败: \(error)")
            return nil
        }
    }

    /// 更新当前活动内容
    func update(mainText: String? = nil, secondaryText: String? = nil, endDate: Date? = nil) {
        guard let activity = currentActivity else { return }
        var state = activity.contentState
        if let mainText { state.mainText = mainText }
        if let secondaryText { state.secondaryText = secondaryText }
        if let endDate { state.endDate = endDate }
        Task {
            await activity.update(using: state)
        }
    }

    /// 结束当前活动
    func endCurrent() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
