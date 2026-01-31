import SwiftUI

struct RetroView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let release = store.selectedRelease {
                        RetroStatsCardView(release: release)
                        RetroQuestionsCardView(release: release)
                        ExportCardView(release: release)
                    }
                }
                .padding()
            }
            .navigationTitle("复盘")
        }
    }
}

private struct RetroStatsCardView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("数据概览")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("完成数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(store.doneCount(for: release))")
                        .font(.title2)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("目标达成")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(store.goalCompletionCount(for: release))/\(release.goals.count)")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct RetroQuestionsCardView: View {
    @EnvironmentObject private var store: AppStore
    let release: ReleaseMonth
    @State private var rightThings = ""
    @State private var wrongThings = ""
    @State private var nextActions = ""
    @State private var summary = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("复盘模板")
                .font(.headline)
            RetroField(title: "本月做对了什么？", text: $rightThings)
            RetroField(title: "哪些没做好？为什么？", text: $wrongThings)
            RetroField(title: "下月要继续/停止/开始什么？", text: $nextActions)
            RetroField(title: "一句话总结本月版本", text: $summary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            rightThings = release.retro.rightThings
            wrongThings = release.retro.wrongThings
            nextActions = release.retro.nextActions
            summary = release.retro.oneLineSummary
        }
        .onChange(of: rightThings) { _, _ in
            save()
        }
        .onChange(of: wrongThings) { _, _ in
            save()
        }
        .onChange(of: nextActions) { _, _ in
            save()
        }
        .onChange(of: summary) { _, _ in
            save()
        }
    }

    private func save() {
        var updated = release
        updated.retro.rightThings = rightThings
        updated.retro.wrongThings = wrongThings
        updated.retro.nextActions = nextActions
        updated.retro.oneLineSummary = summary
        updated.updatedAt = Date()
        store.updateSelectedRelease(updated)
    }
}

private struct RetroField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
            TextEditor(text: $text)
                .frame(minHeight: 80)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
        }
    }
}

private struct ExportCardView: View {
    let release: ReleaseMonth

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Release Notes 导出")
                .font(.headline)
            Text("导出图片 / PDF 的功能将在实现阶段接入渲染逻辑。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Button("预览") {}
                    .buttonStyle(.bordered)
                Button("导出") {}
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RetroView()
        .environmentObject(AppStore())
}
