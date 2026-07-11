//
//  PopPangInteractiveSwiftUIView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import PopPangListKit
import SwiftUI
import UIKit

struct PopPangInteractiveSwiftUIView: View {
    struct Item: Identifiable, Equatable {
        let id: UUID
        let title: String
        var isEnabled: Bool
        var count: Int

        init(
            id: UUID = UUID(),
            title: String,
            isEnabled: Bool = false,
            count: Int = 0
        ) {
            self.id = id
            self.title = title
            self.isEnabled = isEnabled
            self.count = count
        }
    }

    @State private var items = (1...50).map {
        Item(title: "Interactive Cell \($0)")
    }

    var body: some View {
        PopPangList {
            Section(id: "interactive") {
                for item in items {
                    Cell(
                        id: item.id,
                        item: item,
                        layoutMode: .flexibleHeight(estimatedHeight: 120)
                    ) { item in
                        InteractiveRow(
                            item: item,
                            onToggle: { isEnabled in
                                updateItem(id: item.id) {
                                    $0.isEnabled = isEnabled
                                }
                            },
                            onIncrement: {
                                updateItem(id: item.id) {
                                    $0.count += 1
                                }
                            }
                        )
                    }
                }
            }
            .withSectionLayout(
                VerticalLayout(spacing: 12)
                    .insets(
                        NSDirectionalEdgeInsets(
                            top: 16,
                            leading: 16,
                            bottom: 24,
                            trailing: 16
                        )
                    )
            )
        }
        .navigationTitle("Interactive Cells")
        .navigationBarTitleDisplayMode(.inline)
    }

    @MainActor
    private func updateItem(
        id: UUID,
        update: (inout Item) -> Void
    ) {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return
        }

        update(&items[index])
    }
}

private struct InteractiveRow: View {
    let item: PopPangInteractiveSwiftUIView.Item
    let onToggle: (Bool) -> Void
    let onIncrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)

                    Text(item.isEnabled ? "활성화됨" : "비활성화됨")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Count \(item.count)")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.background, in: Capsule())
            }

            HStack(spacing: 16) {
                Toggle(
                    "상태",
                    isOn: Binding(
                        get: { item.isEnabled },
                        set: onToggle
                    )
                )

                Button("+1", action: onIncrement)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            item.isEnabled ? Color.green.opacity(0.16) : Color.secondary.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    item.isEnabled ? Color.green : Color.secondary.opacity(0.25),
                    lineWidth: 1
                )
        }
    }
}
