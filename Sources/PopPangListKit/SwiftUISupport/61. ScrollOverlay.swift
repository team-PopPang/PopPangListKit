//
//  ScrollOverlay.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/15/26.
//

import Combine
import SwiftUI

/// `PopPangList` scroll overlay의 표시 기준입니다.
public enum ScrollOverlayVisibility: Hashable, Sendable {
    /// 현재 viewport 높이의 배수만큼 세로 스크롤한 뒤 표시합니다.
    case relativeToViewport(CGFloat)

    /// 지정한 point만큼 세로 스크롤한 뒤 표시합니다.
    case points(CGFloat)
}

extension ScrollOverlayVisibility {
    func isVisible(
        contentOffsetY: CGFloat,
        adjustedContentInsetTop: CGFloat,
        viewportHeight: CGFloat
    ) -> Bool {
        // UICollectionView starts at -adjustedContentInset.top, so add the inset
        // to measure the distance travelled from the actual content top.
        let offsetY = max(0, contentOffsetY + adjustedContentInsetTop)
        return offsetY > threshold(viewportHeight: viewportHeight)
    }

    private func threshold(viewportHeight: CGFloat) -> CGFloat {
        switch self {
        case let .relativeToViewport(ratio):
            max(0, viewportHeight) * max(0, ratio)
        case let .points(points):
            max(0, points)
        }
    }
}

// MARK: - SwiftUI+ Internal State
@MainActor
final class ScrollOverlayVisibilityState: ObservableObject {
    @Published private(set) var isVisible = false

    private var visibleWhen: ScrollOverlayVisibility?

    func update(visibleWhen: ScrollOverlayVisibility?) {
        self.visibleWhen = visibleWhen

        guard visibleWhen != nil else {
            isVisible = false
            return
        }
    }

    func update(
        contentOffsetY: CGFloat,
        adjustedContentInsetTop: CGFloat,
        viewportHeight: CGFloat
    ) {
        guard let visibleWhen else {
            isVisible = false
            return
        }

        let nextIsVisible = visibleWhen.isVisible(
            contentOffsetY: contentOffsetY,
            adjustedContentInsetTop: adjustedContentInsetTop,
            viewportHeight: viewportHeight
        )

        guard isVisible != nextIsVisible else {
            return
        }

        isVisible = nextIsVisible
    }
}

// MARK: - SwiftUI+ Internal Configuration
struct ScrollOverlayConfiguration {
    let state: ScrollOverlayVisibilityState
    let visibleWhen: ScrollOverlayVisibility
}

extension PopPangList {
    /// 스크롤 위치에 맞춰 표시 상태를 전달하는 SwiftUI overlay를 추가합니다.
    ///
    /// `content`는 상태가 바뀔 때만 다시 계산됩니다. List snapshot은 다시 적용하지 않습니다.
    public func scrollOverlay<Overlay: View>(
        alignment: Alignment = .bottomTrailing,
        visibleWhen: ScrollOverlayVisibility,
        @ViewBuilder content: @escaping (Bool) -> Overlay
    ) -> some View {
        PopPangListScrollOverlay(
            list: self,
            alignment: alignment,
            visibleWhen: visibleWhen,
            content: content
        )
    }
}

@MainActor
private struct PopPangListScrollOverlay<Overlay: View>: View {
    private let list: PopPangList
    private let alignment: Alignment
    private let visibleWhen: ScrollOverlayVisibility
    private let content: (Bool) -> Overlay

    @State private var visibilityState: ScrollOverlayVisibilityState

    init(
        list: PopPangList,
        alignment: Alignment,
        visibleWhen: ScrollOverlayVisibility,
        @ViewBuilder content: @escaping (Bool) -> Overlay
    ) {
        self.list = list
        self.alignment = alignment
        self.visibleWhen = visibleWhen
        self.content = content
        _visibilityState = State(initialValue: .init())
    }

    var body: some View {
        list
            .applyingScrollOverlay(
                state: visibilityState,
                visibleWhen: visibleWhen
            )
            .overlay(
                ScrollOverlayContent(
                    state: visibilityState,
                    content: content
                ),
                alignment: alignment
            )
    }
}

@MainActor
private struct ScrollOverlayContent<Overlay: View>: View {
    @ObservedObject var state: ScrollOverlayVisibilityState

    private let content: (Bool) -> Overlay

    init(
        state: ScrollOverlayVisibilityState,
        @ViewBuilder content: @escaping (Bool) -> Overlay
    ) {
        self.state = state
        self.content = content
    }

    var body: some View {
        content(state.isVisible)
            .opacity(state.isVisible ? 1 : 0)
            .allowsHitTesting(state.isVisible)
            .scrollOverlayAccessibilityHidden(!state.isVisible)
    }
}

private extension View {
    @ViewBuilder
    func scrollOverlayAccessibilityHidden(_ isHidden: Bool) -> some View {
        if #available(iOS 14.0, *) {
            accessibilityHidden(isHidden)
        } else {
            self
        }
    }
}
