import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var releases: [ReleaseMonth]
    @Published var items: [Item]
    @Published var tags: [Tag]
    @Published var selectedMonthId: UUID

    init(now: Date = Date()) {
        let currentMonth = AppStore.currentYearMonth(from: now)
        let release = ReleaseMonth.placeholder(yearMonth: currentMonth)
        releases = [release]
        items = []
        tags = Tag.defaults
        selectedMonthId = release.id
    }

    var selectedRelease: ReleaseMonth? {
        releases.first(where: { $0.id == selectedMonthId })
    }

    func updateSelectedRelease(_ release: ReleaseMonth) {
        guard let index = releases.firstIndex(where: { $0.id == release.id }) else { return }
        releases[index] = release
    }

    func addInboxItem(text: String, tagId: UUID?) {
        let now = Date()
        let newItem = Item(
            id: UUID(),
            text: text,
            tagId: tagId,
            status: .inbox,
            releaseMonthId: nil,
            note: "",
            createdAt: now,
            updatedAt: now,
            doneAt: nil
        )
        items.insert(newItem, at: 0)
    }

    func moveItem(_ item: Item, to status: Item.Status, releaseId: UUID?) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = items[index]
        updated.status = status
        updated.releaseMonthId = releaseId
        updated.updatedAt = Date()
        if status == .done {
            updated.doneAt = Date()
        }
        items[index] = updated
    }

    func items(for status: Item.Status, releaseId: UUID?) -> [Item] {
        items
            .filter { $0.status == status && $0.releaseMonthId == releaseId }
            .sorted(by: { lhs, rhs in
                (lhs.doneAt ?? lhs.createdAt) > (rhs.doneAt ?? rhs.createdAt)
            })
    }

    func inboxItems() -> [Item] {
        items
            .filter { $0.status == .inbox }
            .sorted(by: { $0.createdAt > $1.createdAt })
    }

    func tagName(for tagId: UUID?) -> String {
        guard let tagId else { return "" }
        return tags.first(where: { $0.id == tagId })?.name ?? ""
    }

    func goalCompletionCount(for release: ReleaseMonth) -> Int {
        release.goals.filter { $0.isAchieved }.count
    }

    func doneCount(for release: ReleaseMonth) -> Int {
        items(for: .done, releaseId: release.id).count
    }

    static func currentYearMonth(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
