import PopPangListKit
import SwiftUI
import UIKit

/// 빈 section들이 먼저 layout된 뒤 동일한 section ID에 데이터가 삽입되는 상황을 재현합니다.
struct AsyncPopupLayoutExample: View {
    @State private var data = PopupData.empty
    @State private var loadID = UUID()
    @State private var listProxy = ListProxy()

    var body: some View {
        VStack(spacing: 0) {
            AsyncPopupTopBar(
                isLoaded: !data.coming.isEmpty,
                onReplay: replay
            )

            PopPangList(proxy: listProxy) {
                recommendedSection
                comingSoonSection
                gridSection
            }
            .scrollOverlay(
                alignment: .bottomTrailing,
                visibleWhen: .relativeToViewport(1.5)
            ) { isVisible in
                if isVisible {
                    AsyncPopupTopAnchorButton {
                        _ = listProxy.scrollToSection(
                            id: "async-grid",
                            position: .top,
                            animated: true
                        )
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Async Layout Reproduction")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: loadID) {
            await loadPopupsAfterDelay()
        }
    }

    private var recommendedSection: PopPangListKit.Section {
        Section(id: "async-recommended") {
            For(data.recommended, id: \.id) { popup in
                RecommendedPopupCard(popup: popup)
                    .frame(width: 194, height: 271)
            }
            .layoutMode(
                .fitContent(
                    estimatedSize: .init(width: 194, height: 271)
                )
            )
        }
        .withHeader {
            RecommendedSectionHeader()
        }
        .headerBackground(.systemBackground)
        .withSectionLayout(
            HorizontalLayout(
                spacing: 15,
                scrollingBehavior: .continuousGroupLeadingBoundary
            )
            .insets(.init(top: 0, leading: 20, bottom: 42, trailing: 20))
            .headerPinToVisibleBounds(true)
        )
    }

    private var comingSoonSection: PopPangListKit.Section {
        Section(id: "async-coming") {
            For(data.coming, id: \.id) { popup in
                ComingSoonPopupCard(popup: popup)
                    .frame(width: 283, height: 138)
            }
            .layoutMode(
                .fitContent(
                    estimatedSize: .init(width: 283, height: 138)
                )
            )
        }
        .withHeader {
            ComingSoonSectionHeader()
        }
        .headerBackground(.systemBackground)
        .withSectionLayout(
            HorizontalLayout(
                spacing: 15,
                scrollingBehavior: .groupPaging
            )
            .insets(.init(top: 0, leading: 20, bottom: 65, trailing: 20))
            .headerPinToVisibleBounds(true)
        )
    }

    private var gridSection: PopPangListKit.Section {
        Section(id: "async-grid") {
            For(data.grid, id: \.id) { popup in
                GridPopupCard(
                    popup: popup,
                    onLike: {
                        toggleLike(popupID: popup.id)
                    }
                )
            }
            .layoutMode(.flexibleHeight(estimatedHeight: 302))
        }
        .withHeader {
            GridSectionHeader()
        }
        .headerBackground(.systemBackground)
        .withSectionLayout(
            VerticalGridLayout(
                numberOfItemsInRow: 2,
                itemSpacing: 15,
                lineSpacing: 22
            )
            .insets(.init(top: 0, leading: 20, bottom: 32, trailing: 20))
            .headerPinToVisibleBounds(true)
        )
    }

    @MainActor
    private func loadPopupsAfterDelay() async {
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000)
        } catch {
            return
        }

        guard !Task.isCancelled else {
            return
        }
        data = .loaded
    }

    @MainActor
    private func toggleLike(popupID: String) {
        guard let index = data.grid.firstIndex(where: { $0.id == popupID }),
              !data.grid[index].isLikeUpdating else {
            return
        }

        data.grid[index].isLikeUpdating = true

        Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 800_000_000)
            } catch {
                if let index = data.grid.firstIndex(where: { $0.id == popupID }) {
                    data.grid[index].isLikeUpdating = false
                }
                return
            }

            guard let index = data.grid.firstIndex(where: { $0.id == popupID }) else {
                return
            }
            data.grid[index].isLiked.toggle()
            data.grid[index].isLikeUpdating = false
        }
    }

    private func replay() {
        data = .empty
        loadID = UUID()
    }
}

private extension AsyncPopupLayoutExample {
    struct Popup: Identifiable, Equatable {
        let id: String
        let title: String
        let location: String
        let countdown: String
        var isLiked = false
        var isLikeUpdating = false
    }

    struct PopupData: Equatable {
        var recommended: [Popup]
        var coming: [Popup]
        var grid: [Popup]

        static let empty = PopupData(
            recommended: [],
            coming: [],
            grid: []
        )

        static let loaded = PopupData(
            recommended: [
                Popup(
                    id: "recommended-1",
                    title: "홍대 디저트 마켓",
                    location: "서울 마포구",
                    countdown: "OPEN"
                ),
                Popup(
                    id: "recommended-2",
                    title: "더현대 패션 쇼룸",
                    location: "서울 영등포구",
                    countdown: "OPEN"
                ),
                Popup(
                    id: "recommended-3",
                    title: "성수 크리에이터 스튜디오",
                    location: "서울 성동구",
                    countdown: "OPEN"
                ),
            ],
            coming: [
                Popup(
                    id: "coming-1",
                    title: "성수 라이프스타일 팝업",
                    location: "서울 성동구",
                    countdown: "오픈 D-2"
                ),
                Popup(
                    id: "coming-2",
                    title: "한남 메이커스 쇼룸",
                    location: "서울 용산구",
                    countdown: "오픈 D-5"
                ),
                Popup(
                    id: "coming-3",
                    title: "연남 디자인 마켓",
                    location: "서울 마포구",
                    countdown: "오픈 D-7"
                ),
            ],
            grid: (1...20).map { index in
                let titles = [
                    "메이커스 스튜디오",
                    "시네마 아카이브",
                    "오렌지 뮤직룸",
                    "서울 디자인 위크",
                    "북촌 공예 상점",
                ]
                let locations = [
                    "서울 성동구",
                    "서울 영등포구",
                    "서울 마포구",
                    "서울 중구",
                    "서울 종로구",
                ]

                return Popup(
                    id: "grid-\(index)",
                    title: titles[(index - 1) % titles.count],
                    location: locations[(index - 1) % locations.count],
                    countdown: "진행 중"
                )
            }
        )
    }
}

private struct AsyncPopupTopBar: View {
    let isLoaded: Bool
    let onReplay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("POP PANG")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(PopupPalette.orange)

                Spacer()

                Image(systemName: "magnifyingglass")
                Image(systemName: "bell")

                Button(action: onReplay) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("비동기 로딩 다시 재현")
            }
            .font(.system(size: 19, weight: .medium))

            HStack(spacing: 7) {
                Circle()
                    .fill(isLoaded ? Color.green : PopupPalette.orange)
                    .frame(width: 7, height: 7)
                Text(isLoaded ? "비동기 데이터 반영 완료" : "빈 섹션 layout 중 · 3초 뒤 데이터 반영")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(Color(uiColor: .systemBackground))
    }
}

private struct RecommendedSectionHeader: View {
    var body: some View {
        (Text("홍길동")
            .foregroundStyle(PopupPalette.orange)
         + Text("님을 위한 팝업")
            .foregroundStyle(.primary))
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}

private struct ComingSoonSectionHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("COMING SOON")
                .font(.caption2.weight(.bold))
                .foregroundStyle(PopupPalette.orange)

            HStack {
                Text("오픈 예정 팝업")
                    .font(.title3.weight(.bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

private struct GridSectionHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("전체")
                .font(.title3.weight(.bold))

            Spacer()

            PopupFilterChip(title: "지역")
            PopupFilterChip(title: "최신순")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

private struct PopupFilterChip: View {
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            Text(title)
            Image(systemName: "chevron.down")
                .font(.system(size: 9, weight: .semibold))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay {
            Capsule()
                .stroke(Color.secondary.opacity(0.18))
        }
    }
}

private struct AsyncPopupTopAnchorButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(PopupPalette.orange)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .padding(20)
        .accessibilityLabel("전체 섹션으로 이동")
    }
}

private struct RecommendedPopupCard: View {
    let popup: AsyncPopupLayoutExample.Popup

    var body: some View {
        PopupPoster(popup: popup)
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(popup.title)
                        .font(.headline)
                    Label(popup.location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                }
                .foregroundStyle(.white)
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

private struct ComingSoonPopupCard: View {
    let popup: AsyncPopupLayoutExample.Popup

    var body: some View {
        HStack(spacing: 12) {
            PopupPoster(popup: popup)
                .frame(width: 94, height: 118)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 5) {
                Text(popup.countdown)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(PopupPalette.orange)
                Text(popup.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                Spacer(minLength: 0)
                Text(popup.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.07), radius: 7, y: 2)
    }
}

private struct GridPopupCard: View {
    let popup: AsyncPopupLayoutExample.Popup
    let onLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PopupPoster(popup: popup)
                .frame(height: 217)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .overlay(alignment: .topTrailing) {
                    Button(action: onLike) {
                        Group {
                            if popup.isLikeUpdating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: popup.isLiked ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundStyle(popup.isLiked ? PopupPalette.orange : .white)
                            }
                        }
                        .frame(width: 25, height: 25)
                        .shadow(radius: 2)
                        .padding(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(popup.isLikeUpdating)
                    .accessibilityLabel(popup.isLiked ? "좋아요 취소" : "좋아요")
                    .accessibilityValue(popup.isLikeUpdating ? "처리 중" : "")
                }

            Text(popup.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .padding(.top, 10)
            Text(popup.location)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
            Text("2026.07.16 - 2026.08.16")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


private struct PopupPoster: View {
    let popup: AsyncPopupLayoutExample.Popup
    @State private var isImageLoaded = false

    var body: some View {
        ZStack {
            if isImageLoaded {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.30, green: 0.01, blue: 0.04),
                        Color(red: 0.08, green: 0.01, blue: 0.02),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color(uiColor: .secondarySystemBackground)
                    .overlay {
                        ProgressView()
                            .tint(PopupPalette.orange)
                    }
            }

            VStack(spacing: 8) {
                HStack {
                    Text("POP PANG ORIGINAL")
                    Spacer()
                    Text("P.P")
                }
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.white.opacity(0.72))

                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    Text("MAKER'S")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                    Text("STUDIO")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, PopupPalette.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .red.opacity(0.8), radius: 5)

                Text(popup.title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.64))

                Spacer(minLength: 0)

                HStack {
                    Text("2026.07")
                    Spacer()
                    Text(popup.countdown)
                }
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.white.opacity(0.76))
            }
            .padding(10)
            .opacity(isImageLoaded ? 1 : 0)
        }
        .task(id: popup.id) {
            isImageLoaded = false

            do {
                try await Task.sleep(nanoseconds: 600_000_000)
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }
            withAnimation(.easeOut(duration: 0.2)) {
                isImageLoaded = true
            }
        }
    }
}

private enum PopupPalette {
    static let orange = Color(red: 0.97, green: 0.38, blue: 0.10)
}

#Preview("Async Layout Bug Reproduction") {
    NavigationStack {
        AsyncPopupLayoutExample()
    }
}
