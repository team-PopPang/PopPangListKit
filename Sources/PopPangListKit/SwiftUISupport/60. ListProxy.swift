//
//  ListProxy.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/14/26.
//

import UIKit

/// `ListProxy`가 section으로 이동할 때 사용할 정렬 위치입니다.
public enum PopPangListScrollPosition: Hashable, Sendable {
    case top
    case centeredVertically
    case bottom
    case left
    case centeredHorizontally
    case right
}

extension PopPangListScrollPosition {
    var collectionViewScrollPosition: UICollectionView.ScrollPosition {
        switch self {
        case .top:
            .top
        case .centeredVertically:
            .centeredVertically
        case .bottom:
            .bottom
        case .left:
            .left
        case .centeredHorizontally:
            .centeredHorizontally
        case .right:
            .right
        }
    }
}

@MainActor
protocol PopPangListScrollControlling: AnyObject {
    func scrollToTop(animated: Bool) -> Bool
    func scrollToSection(
        id: AnyHashable,
        position: PopPangListScrollPosition,
        animated: Bool
    ) -> Bool
}

/// SwiftUI `PopPangList`에 프로그램 스크롤 명령을 전달합니다.
///
/// `@State`에서 생성해 `PopPangList(proxy:)`에 전달하세요. 아직 mount되지 않았거나
/// 제거된 List에는 명령을 대기시키지 않고 `false`를 반환합니다.
@MainActor
public final class ListProxy {
    // MARK: - SwiftUI+

    /// 현재 연결된 List controller입니다. 순환 참조를 막기 위해 약하게 보관합니다.
    private weak var scrollController: (any PopPangListScrollControlling)?

    public init() {}
}

extension ListProxy {
    /// 실제 콘텐츠의 최상단으로 이동합니다.
    ///
    /// `adjustedContentInset.top`을 반영합니다. List가 아직 mount되지 않았거나 이미
    /// 제거된 경우에는 이동하지 않고 `false`를 반환합니다.
    @discardableResult
    public func scrollToTop(animated: Bool = true) -> Bool {
        scrollController?.scrollToTop(animated: animated) ?? false
    }

    /// 지정한 section의 첫 번째 Cell로 이동합니다.
    ///
    /// - Returns: List가 연결되어 있고, 현재 snapshot에 `id`가 존재하며 Cell이 하나
    ///   이상인 section으로 이동했으면 `true`를 반환합니다. mount 전, 제거 후, 존재하지
    ///   않는 ID 또는 빈 section은 안전하게 무시하고 `false`를 반환합니다.
    @discardableResult
    public func scrollToSection<ID: Hashable>(
        id: ID,
        position: PopPangListScrollPosition = .top,
        animated: Bool = true
    ) -> Bool {
        scrollController?.scrollToSection(
            id: AnyHashable(id),
            position: position,
            animated: animated
        ) ?? false
    }

    func attach(_ scrollController: any PopPangListScrollControlling) {
        self.scrollController = scrollController
    }

    func detach(_ scrollController: any PopPangListScrollControlling) {
        guard self.scrollController === scrollController else {
            return
        }

        self.scrollController = nil
    }
}

/// `ListProxy`의 이전 이름입니다.
///
/// 기존 호출부는 source-compatible하게 유지되지만, 새 코드에서는 `ListProxy`를 사용하세요.
@available(*, deprecated, renamed: "ListProxy")
public typealias PopPangListProxy = ListProxy
