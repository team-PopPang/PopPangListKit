import PopPangListKit
import SwiftUI
import UIKit

/// 같은 raw Cell ID를 여러 Section에서 안전하게 사용하는 예제입니다.
///
/// `best`와 `grid`는 동일한 Popup 배열과 `popupUuid`를 공유하지만,
/// 서로 다른 SwiftUI Cell View 타입과 크기 규칙을 사용합니다.
struct SectionScopedIdentityExample: View {
    @State private var revision = 1
    @State private var usesAlternateGridCell = false
    @State private var selectedPopupID: String?

    private var popups: [SectionIdentityPopup] {
        [
            SectionIdentityPopup(
                popupUuid: "popup-seongsu",
                title: "성수 크리에이터 마켓",
                location: "서울 성동구",
                revision: revision
            ),
            SectionIdentityPopup(
                popupUuid: "popup-yeonnam",
                title: "연남 디자인 스토어",
                location: "서울 마포구",
                revision: revision
            ),
            SectionIdentityPopup(
                popupUuid: "popup-hannam",
                title: "한남 라이프 쇼룸",
                location: "서울 용산구",
                revision: revision
            ),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            SectionIdentityControls(
                revision: revision,
                usesAlternateGridCell: usesAlternateGridCell,
                selectedPopupID: selectedPopupID,
                onReapply: {
                    revision += 1
                },
                onChangeGridCellType: {
                    usesAlternateGridCell.toggle()
                }
            )

            PopPangList {
                bestSection
                gridSection
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Section-scoped ID")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var bestSection: PopPangListKit.Section {
        Section(id: "best") {
            For(popups, id: \.popupUuid) { popup in
                BestSectionPopupCell(popup: popup)
                    .frame(width: 250, height: 150)
            }
            .layoutMode(
                .fitContent(
                    estimatedSize: CGSize(width: 250, height: 150)
                )
            )
            .didSelect {
                selectedPopupID = $0.popupUuid
            }
        }
        .withHeader {
            SectionIdentityHeader(
                title: "Best Section",
                subtitle: #"Section(id: "best") · BestSectionPopupCell"#
            )
        }
        .headerBackground(.systemBackground)
        .withSectionLayout(
            HorizontalLayout(
                spacing: 12,
                scrollingBehavior: .continuousGroupLeadingBoundary
            )
            .insets(
                NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 28,
                    trailing: 20
                )
            )
        )
    }

    private var gridSection: PopPangListKit.Section {
        Section(id: "grid") {
            if usesAlternateGridCell {
                For(popups, id: \.popupUuid) { popup in
                    AlternateGridSectionPopupCell(popup: popup)
                }
                .layoutMode(.flexibleHeight(estimatedHeight: 210))
                .didSelect {
                    selectedPopupID = $0.popupUuid
                }
            } else {
                For(popups, id: \.popupUuid) { popup in
                    GridSectionPopupCell(popup: popup)
                }
                .layoutMode(.flexibleHeight(estimatedHeight: 180))
                .didSelect {
                    selectedPopupID = $0.popupUuid
                }
            }
        }
        .withHeader {
            SectionIdentityHeader(
                title: "Grid Section",
                subtitle: gridHeaderSubtitle
            )
        }
        .headerBackground(.systemBackground)
        .withSectionLayout(
            VerticalGridLayout(
                numberOfItemsInRow: 2,
                itemSpacing: 12,
                lineSpacing: 16
            )
            .insets(
                NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 28,
                    trailing: 20
                )
            )
        )
    }

    private var gridHeaderSubtitle: String {
        if usesAlternateGridCell {
            return #"Section(id: "grid") · AlternateGridSectionPopupCell"#
        }

        return #"Section(id: "grid") · GridSectionPopupCell"#
    }
}

private struct SectionIdentityPopup: Equatable {
    let popupUuid: String
    let title: String
    let location: String
    let revision: Int
}

private struct SectionIdentityControls: View {
    let revision: Int
    let usesAlternateGridCell: Bool
    let selectedPopupID: String?
    let onReapply: () -> Void
    let onChangeGridCellType: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Label(
                    "같은 popupUuid를 두 Section에서 공유",
                    systemImage: "checkmark.shield.fill"
                )
                .font(.headline)
                .foregroundStyle(.green)

                Text(
                    "prefix나 wrapper 없이 (sectionID, cellID)를 "
                        + "내부 diff와 size cache key로 사용합니다."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Button(action: onReapply) {
                    Label(
                        "Snapshot \(revision)",
                        systemImage: "arrow.clockwise"
                    )
                }
                .buttonStyle(.borderedProminent)

                Button(action: onChangeGridCellType) {
                    Label(
                        usesAlternateGridCell ? "기본 Cell" : "Cell 타입 변경",
                        systemImage: "rectangle.2.swap"
                    )
                }
                .buttonStyle(.bordered)
            }

            Text(
                selectedPopupID.map { "선택된 원본 ID: \($0)" }
                    ?? "Cell을 선택하면 원본 popupUuid가 표시됩니다."
            )
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

private struct SectionIdentityHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

private struct BestSectionPopupCell: View {
    let popup: SectionIdentityPopup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("BEST")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(.orange, in: Capsule())

                Spacer()

                Text("snapshot \(popup.revision)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Text(popup.title)
                .font(.headline)
            Text(popup.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(popup.popupUuid)
                .font(.caption2.monospaced())
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.18), .yellow.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.orange.opacity(0.3))
        }
    }
}

private struct GridSectionPopupCell: View {
    let popup: SectionIdentityPopup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.opacity(0.15))
                .frame(height: 78)
                .overlay {
                    Image(systemName: "square.grid.2x2")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

            Text(popup.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Text(popup.location)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(popup.popupUuid) · \(popup.revision)")
                .font(.caption2.monospaced())
                .foregroundStyle(.blue)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.blue.opacity(0.22))
        }
    }
}

private struct AlternateGridSectionPopupCell: View {
    let popup: SectionIdentityPopup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "rectangle.2.swap")
                    .font(.title2)
                Spacer()
                Text("RELOADED")
                    .font(.caption2.weight(.black))
            }
            .foregroundStyle(.purple)

            Text(popup.title)
                .font(.headline)
            Text("다른 SwiftUI View 타입")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.purple)
            Text(popup.location)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text("\(popup.popupUuid) · snapshot \(popup.revision)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.purple.opacity(0.3))
        }
    }
}

#Preview {
    NavigationStack {
        SectionScopedIdentityExample()
    }
}
