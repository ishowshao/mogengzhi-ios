import SwiftUI

struct MonthView: View {
    @EnvironmentObject private var store: AppStore
    @State private var newBacklogText = ""

    var body: some View {
        NavigationStack {
            if let release = store.selectedRelease {
                ScrollView {
                    VStack(spacing: 16) {
                        MonthHeaderView(release: release)

                        ThemeCardView(release: release)

                        GoalsCardView(release: release)

                        BacklogCardView(release: release, newText: $newBacklogText)

                        DoneCardView(release: release)
                    }
                    .padding()
                }
                .navigationTitle(release.yearMonth)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("暂无版本", systemImage: "calendar.badge.exclamationmark", description: Text("请先创建一个月度版本"))
            }
        }
    }
}

private struct MonthHeaderView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth

    var body: some View {
        HStack {
            Text("版本月份")
                .font(.headline)
            Spacer()
            Picker("月份", selection: $store.selectedMonthId) {
                ForEach(store.releases) { release in
                    Text(release.yearMonth).tag(release.id)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ThemeCardView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth
    @State private var theme: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本月主题")
                .font(.headline)
            TextField("可留空", text: $theme)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            theme = release.theme
        }
        .onChange(of: theme) { _, newValue in
            var updated = release
            updated.theme = newValue
            updated.updatedAt = Date()
            store.updateSelectedRelease(updated)
        }
    }
}

private struct GoalsCardView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("本月目标")
                    .font(.headline)
                Spacer()
                Text("已完成 \(store.goalCompletionCount(for: release))/\(release.goals.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(release.goals) { goal in
                HStack {
                    Button {
                        toggleGoal(goal)
                    } label: {
                        Image(systemName: goal.isAchieved ? "checkmark.circle.fill" : "circle")
                    }
                    TextField("目标", text: binding(for: goal))
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func toggleGoal(_ goal: Goal) {
        var updated = release
        guard let index = updated.goals.firstIndex(where: { $0.id == goal.id }) else { return }
        updated.goals[index].isAchieved.toggle()
        updated.updatedAt = Date()
        store.updateSelectedRelease(updated)
    }

    private func binding(for goal: Goal) -> Binding<String> {
        Binding(
            get: {
                release.goals.first(where: { $0.id == goal.id })?.text ?? ""
            },
            set: { newValue in
                var updated = release
                guard let index = updated.goals.firstIndex(where: { $0.id == goal.id }) else { return }
                updated.goals[index].text = newValue
                updated.updatedAt = Date()
                store.updateSelectedRelease(updated)
            }
        )
    }
}

private struct BacklogCardView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth
    @Binding var newText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Backlog")
                .font(.headline)
            HStack {
                TextField("添加待办", text: $newText)
                    .textFieldStyle(.roundedBorder)
                Button("添加") {
                    addBacklogItem()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            let backlogItems = store.items(for: .backlog, releaseId: release.id)
            if backlogItems.isEmpty {
                Text("暂无待办，去 Inbox 归档吧")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(backlogItems) { item in
                        ItemRowView(item: item, tagName: store.tagName(for: item.tagId)) {
                            store.moveItem(item, to: .done, releaseId: release.id)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func addBacklogItem() {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addInboxItem(text: trimmed, tagId: nil)
        if let added = store.items.first {
            store.moveItem(added, to: .backlog, releaseId: release.id)
        }
        newText = ""
    }
}

private struct DoneCardView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Done")
                    .font(.headline)
                Spacer()
                Text("完成 \(store.doneCount(for: release))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            let doneItems = store.items(for: .done, releaseId: release.id)
            if doneItems.isEmpty {
                Text("本月还没有完成记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(doneItems) { item in
                        DoneItemRowView(item: item, tagName: store.tagName(for: item.tagId))
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ItemRowView: View {
    let item: Item
    let tagName: String
    let onComplete: () -> Void

    var body: some View {
        HStack {
            Button(action: onComplete) {
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(item.text)
                if !tagName.isEmpty {
                    Text(tagName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct DoneItemRowView: View {
    @EnvironmentObject private var store: AppStore
    let item: Item
    let tagName: String
    @State private var note: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(item.text)
                Spacer()
            }
            if !tagName.isEmpty {
                Text(tagName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            TextField("亮点/备注", text: $note)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
        }
        .padding(8)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .onAppear {
            note = item.note
        }
        .onChange(of: note) { _, newValue in
            guard let index = store.items.firstIndex(where: { $0.id == item.id }) else { return }
            store.items[index].note = newValue
            store.items[index].updatedAt = Date()
        }
    }
}

#Preview {
    MonthView()
        .environmentObject(AppStore())
}
