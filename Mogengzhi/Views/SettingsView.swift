import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var newTagName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TagManagementCardView(newTagName: $newTagName)
                    BackupCardView()
                    PrivacyCardView()
                }
                .padding()
            }
            .navigationTitle("设置")
        }
    }
}

private struct TagManagementCardView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var newTagName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("标签管理")
                .font(.headline)
            HStack {
                TextField("新增标签", text: $newTagName)
                    .textFieldStyle(.roundedBorder)
                Button("添加") {
                    addTag()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            VStack(spacing: 8) {
                ForEach(store.tags.sorted(by: { $0.order < $1.order })) { tag in
                    HStack {
                        Text(tag.name)
                        Spacer()
                    }
                    .padding(8)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func addTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newTag = Tag(id: UUID(), name: trimmed, order: store.tags.count)
        store.tags.append(newTag)
        newTagName = ""
    }
}

private struct BackupCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("备份与恢复")
                .font(.headline)
            Text("导出/恢复功能将在数据持久化接入后启用。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Button("导出备份") {}
                    .buttonStyle(.bordered)
                Button("从备份恢复") {}
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct PrivacyCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("隐私说明")
                .font(.headline)
            Text("所有数据默认仅存本地，不接入任何第三方统计或服务端。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStore())
}
