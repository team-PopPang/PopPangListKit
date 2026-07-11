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
                for index in items.indices {
                    let item = $items[index]

                    Cell(
                        id: item.wrappedValue.id,
                        item: item,
                        layoutMode: .flexibleHeight(estimatedHeight: 120)
                    ) { item in
                        InteractiveRow(item: item)
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

}

private struct InteractiveRow: View {
    @Binding var item: PopPangInteractiveSwiftUIView.Item

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
                Toggle("상태", isOn: $item.isEnabled)

                Button("+1") {
                    item.count += 1
                }
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
