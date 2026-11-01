import ActivityKit
import Foundation

/// 灵动岛内容类型
enum IslandMode: String, Codable, Hashable {
    case code       // 取餐码 / 取件码
    case timer      // 倒计时
    case text       // 自定义文字
    case reminder   // 定时提醒
}

/// 灵动岛实时活动属性（App 与 Widget 共享）
struct IslandActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var mode: IslandMode
        var mainText: String
        var secondaryText: String
        var endDate: Date?
    }

    var title: String
}
