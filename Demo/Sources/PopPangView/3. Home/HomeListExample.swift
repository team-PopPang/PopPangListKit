import PopPangListKit
import SwiftUI
import UIKit

/// 기존 List DSL만으로 구성한 PopPang 홈 카드 예제입니다.
struct HomeListExample: View {
    struct Card: Identifiable, Equatable {
        let id: Int
        let title: String
        let subtitle: String
        var isFavorite = false
    }

    @State private var featuredCards = (1...8).map {
        Card(id: $0, title: "추천 팝업 \($0)", subtitle: "가로 연속 스크롤")
    }
    @State private var comingCards = (1...6).map {
        Card(id: $0, title: "오픈 예정 \($0)", subtitle: "카드 단위 group paging")
    }
    @State private var gridCards = (1...18).map {
        Card(id: $0, title: "그리드 \($0)", subtitle: "2열 카드")
    }

    var body: some View {
        PopPangList {
            Section(id: "featured") {
                For(
                    featuredCards,
                    id: \.id,
                    layoutMode: .fitContent(
                        estimatedSize: .init(width: 194, height: 172)
                    )
                ) { card in
                    HomeCardView(card: card, color: .purple)
                        .frame(width: 194, height: 172)
                }
            }
            .withHeader {
                HomeSectionHeader(
                    title: "추천 \(featuredCards.count)개",
                    subtitle: "기존 Cell layoutMode로 카드 크기를 선언합니다"
                )
            }
            .withSectionLayout(
                HorizontalLayout(
                    spacing: 15,
                    scrollingBehavior: .continuousGroupLeadingBoundary
                )
                .insets(.init(top: 0, leading: 20, bottom: 28, trailing: 20))
                .headerPinToVisibleBounds(true)
            )

            Section(id: "coming") {
                For(
                    comingCards,
                    id: \.id,
                    layoutMode: .fitContent(
                        estimatedSize: .init(width: 282, height: 126)
                    )
                ) { card in
                    HomeCardView(card: card, color: .orange)
                        .frame(width: 282, height: 126)
                }
            }
            .withHeader {
                HomeSectionHeader(
                    title: "오픈 예정 \(comingCards.count)개",
                    subtitle: "한 카드씩 멈추는 group paging"
                )
            }
            .withSectionLayout(
                HorizontalLayout(
                    spacing: 15,
                    scrollingBehavior: .groupPaging
                )
                .insets(.init(top: 0, leading: 20, bottom: 28, trailing: 20))
                .headerPinToVisibleBounds(true)
            )

            Section(id: "grid") {
                For(
                    gridCards,
                    id: \.id,
                    layoutMode: .flexibleHeight(estimatedHeight: 172)
                ) { card in
                    HomeGridCard(card: card)
                        .frame(height: 172)
                }
                .didSelect { card in
                    toggleFavorite(for: card.id)
                }
            }
            .withHeader {
                HomeSectionHeader(
                    title: "전체 팝업",
                    subtitle: "기존 VerticalGridLayout을 그대로 사용합니다"
                )
            }
            .withSectionLayout(
                VerticalGridLayout(
                    numberOfItemsInRow: 2,
                    itemSpacing: 15,
                    lineSpacing: 20
                )
                .insets(.init(top: 0, leading: 20, bottom: 24, trailing: 20))
                .headerPinToVisibleBounds(true)
            )
        }
        .navigationTitle("Home List")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleFavorite(for id: Int) {
        guard let index = gridCards.firstIndex(where: { $0.id == id }) else {
            return
        }
        gridCards[index].isFavorite.toggle()
    }
}

private struct HomeSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(uiColor: .systemBackground))
    }
}

private struct HomeCardView: View {
    let card: HomeListExample.Card
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.title)
                .font(.headline)
            Text(card.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Label("상세 보기", systemImage: "arrow.right")
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct HomeGridCard: View {
    let card: HomeListExample.Card

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.opacity(0.16))
                .frame(height: 84)
                .overlay(Text("POPUP").font(.caption.weight(.bold)))
            Text(card.title)
                .font(.subheadline.weight(.semibold))
            Text(card.isFavorite ? "찜한 팝업" : card.subtitle)
                .font(.caption)
                .foregroundStyle(card.isFavorite ? .pink : .secondary)
            Spacer(minLength: 0)
            Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(.pink)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2))
        }
    }
}
