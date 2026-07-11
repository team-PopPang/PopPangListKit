//
//  PopPangSwiftUIView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import PopPangListKit
import SwiftUI
import UIKit

struct PopPangSwiftUIView: View {
    private enum Const {
        static let pageSize = 100
        static let maximumItemCount = 10_000
    }

    struct Item: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String

        init(
            id: UUID = UUID(),
            title: String,
            subtitle: String
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }
    }

    @State private var items: [Item] = (0..<Const.pageSize).map { index in
        Item(
            title: "SwiftUI 셀 \(index + 1)",
            subtitle: UUID().uuidString
        )
    }

    @State private var isLoadingMore = false

    var body: some View {
        PopPangList(
            configuration: CollectionViewAdapterConfiguration(
                refreshControl: .enabled(
                    tintColor: .systemGray,
                    text: "새로고침 중..."
                )
            )
        ) {
            Section(id: "main") {
                // 기존 UIKit Component
                Cell(
                    id: "uikit",
                    component: VerticalLayoutComponent(
                        item: makeUIKitItem()
                    )
                )

                // SwiftUI View
                for item in items {
                    Cell(
                        id: item.id,
                        item: item
                    ) { item in
                        SwiftUIRow(item: item)
                            .padding(.vertical, 12)
                    }
                    .didSelect { _ in
                        print("선택:", item.id)
                    }
                    .onHighlight { _ in
                        print("눌림:", item.title)
                    }
                    .onUnhighlight { _ in
                        print("눌림 취소:", item.title)
                    }
                }
            }
            .withHeader(
                SectionHeaderComponent(
                    item: .init(
                        title: "헤더 타이틀",
                        subtitle: "현재 \(items.count)개"
                    )
                )
            )
            .withSectionLayout(
                VerticalLayout(spacing: 8)
                    .insets(
                        NSDirectionalEdgeInsets(
                            top: 16,
                            leading: 20,
                            bottom: 16,
                            trailing: 20
                        )
                    )
            )
        }
        .onRefresh { _ in
            Task { @MainActor in
                await Task.yield()
                resetItems()
            }
        }
        .onReachEnd(
            offsetFromEnd: .relativeToContainerSize(
                multiplier: 1
            )
        ) { _ in
            Task { @MainActor in
                await Task.yield()
                appendItems()
            }
        }
    }

    @MainActor
    private func resetItems() {
        items = makeItems(
            startIndex: 0,
            count: Const.pageSize
        )

        print("✅ resetItems:", items.count)
    }

    @MainActor
    private func appendItems() {
        guard isLoadingMore == false else {
            return
        }

        guard items.count < Const.maximumItemCount else {
            print("✅ maximumItemCount:", items.count)
            return
        }

        isLoadingMore = true
        defer {
            isLoadingMore = false
        }

        let remainingCount = Const.maximumItemCount - items.count
        let nextCount = min(Const.pageSize, remainingCount)
        let startIndex = items.count

        items.append(
            contentsOf: makeItems(
                startIndex: startIndex,
                count: nextCount
            )
        )

        print("✅ appendItems:", items.count)
    }

    private func makeItems(
        startIndex: Int,
        count: Int
    ) -> [Item] {
        (0..<count).map { offset in
            let number = startIndex + offset + 1

            return Item(
                title: "SwiftUI 셀 \(number)",
                subtitle: UUID().uuidString
            )
        }
    }

    private func makeUIKitItem() -> VerticalLayoutComponent.Item {
        .init(
            title: "기존 UIKit Component",
            subtitle: "SwiftUI Cell과 같은 Section에 포함"
        )
    }
}

private struct SwiftUIRow: View {
    let item: PopPangSwiftUIView.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)

            Text(item.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .contentShape(Rectangle())
    }
}
