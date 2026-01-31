import SwiftUI

struct InboxView: View {
    @EnvironmentObject private var store: AppStore
    @State private var newText = ""
    @State private var selectedTagId: UUID?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                inboxInputCard
                inboxList
            }
            .padding()
            .navigationTitle("Inbox")
        }
    }

    private var inboxInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速收集")
                .font(.headline)
            TextField("记录一句话", text: $newText)
                .textFieldStyle(.roundedBorder)
            TagPickerView(selectedTagId: $selectedTagId)
            Button("保存到 Inbox") {
                addInboxItem()
            }
            .buttonStyle(.borderedProminent)
            .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var inboxList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("待整理")
                .font(.headline)
            let inboxItems = store.inboxItems()
            if inboxItems.isEmpty {
                Text("Inbox 为空")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(inboxItems) { item in
                        InboxRowView(item: item, tagName: store.tagName(for: item.tagId))
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func addInboxItem() {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addInboxItem(text: trimmed, tagId: selectedTagId)
        newText = ""
    }
}

private struct InboxRowView: View {
    @EnvironmentObject private var store: AppStore
    let item: Item
    let tagName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.text)
            HStack {
                if !tagName.isEmpty {
                    Text(tagName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("归档") {
                    if let release = store.selectedRelease {
                        store.moveItem(item, to: .backlog, releaseId: release.id)
                    }
                }
                .buttonStyle(.bordered)
                Button("完成") {
                    if let release = store.selectedRelease {
                        store.moveItem(item, to: .done, releaseId: release.id)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(8)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct TagPickerView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTagId: UUID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.tags) { tag in
                    Button {
                        selectedTagId = tag.id
                    } label: {
                        Text(tag.name)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedTagId == tag.id ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    InboxView()
        .environmentObject(AppStore())
}
