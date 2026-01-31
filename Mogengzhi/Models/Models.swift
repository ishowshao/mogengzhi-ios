import Foundation

struct ReleaseMonth: Identifiable, Equatable, Hashable {
    let id: UUID
    var yearMonth: String
    var theme: String
    var goals: [Goal]
    var retro: Retro
    var createdAt: Date
    var updatedAt: Date
}

struct Item: Identifiable, Equatable, Hashable {
    enum Status: String, CaseIterable {
        case inbox
        case backlog
        case done
    }

    let id: UUID
    var text: String
    var tagId: UUID?
    var status: Status
    var releaseMonthId: UUID?
    var note: String
    var createdAt: Date
    var updatedAt: Date
    var doneAt: Date?
}

struct Tag: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var order: Int
}

struct Goal: Identifiable, Equatable, Hashable {
    let id: UUID
    var text: String
    var isAchieved: Bool
}

struct Retro: Equatable, Hashable {
    var rightThings: String
    var wrongThings: String
    var nextActions: String
    var oneLineSummary: String
}

extension ReleaseMonth {
    static func placeholder(yearMonth: String) -> ReleaseMonth {
        ReleaseMonth(
            id: UUID(),
            yearMonth: yearMonth,
            theme: "",
            goals: [
                Goal(id: UUID(), text: "设定 3 个本月目标", isAchieved: false),
                Goal(id: UUID(), text: "每周整理一次 Inbox", isAchieved: false),
                Goal(id: UUID(), text: "完成月末复盘", isAchieved: false)
            ],
            retro: Retro(rightThings: "", wrongThings: "", nextActions: "", oneLineSummary: ""),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

extension Tag {
    static let defaults: [Tag] = [
        Tag(id: UUID(), name: "工作", order: 0),
        Tag(id: UUID(), name: "生活", order: 1),
        Tag(id: UUID(), name: "健康", order: 2),
        Tag(id: UUID(), name: "学习", order: 3),
        Tag(id: UUID(), name: "家庭", order: 4),
        Tag(id: UUID(), name: "兴趣", order: 5)
    ]
}
