//
//  DefaultCompositionalLayoutSectionFactory.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 기본 레이아웃을 제공하는 객체입니다.
///
/// 미리 정의된 레이아웃을 사용하면 다양한 스타일의 레이아웃을 빠르고 쉽게 구현할 수 있습니다.
/// 만약 커스텀 레이아웃이 필요하다면,
/// `CompositionalLayoutSectionFactory`를 따르는 객체를 직접 구현하면 됩니다.
@MainActor
public struct DefaultCompositionalLayoutSectionFactory: @MainActor CompositionalLayoutSectionFactory {
    
    /// LayoutSpec은 제공 가능한 레이아웃 타입을 정의합니다.
    public enum LayoutSpec {
        
        /// 간격이 지정된 세로 레이아웃
        case vertical(spacing: CGFloat)
        
        /// 간격 + 스크롤 방식이 지정된 가로 레이아웃
        case horizontal(
            spacing: CGFloat,
            scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
        )
        
        /// 한 줄 아이템 수 + 간격이 지정된 세로 그리드 레이아웃
        case verticalGrid(
            numberOfItemsInRow: Int,
            itemSpacing: CGFloat,
            lineSpacing: CGFloat
        )
    }
    
    /// 현재 사용할 레이아웃 스펙
    private let spec: LayoutSpec
    
    /// 섹션 여백
    private var sectionContentInsets: NSDirectionalEdgeInsets?
    
    /// 헤더 고정 여부
    private var headerPinToVisibleBounds: Bool?
    
    /// 푸터 고정 여부
    private var footerPinToVisibleBounds: Bool?
    
    /// visible item 변경 시 호출되는 핸들러
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
}

// MARK: - Static
extension DefaultCompositionalLayoutSectionFactory {
    /// 기본 세로 레이아웃 생성 (spacing = 0)
    public static let vertical: Self = .init(spec: .vertical(spacing: 0))
    
    /// 기본 가로 레이아웃 생성 (spacing = 0, continuous scroll)
    public static let horizontal: Self = .init(
        spec: .horizontal(
            spacing: 0,
            scrollingBehavior: .continuous)
    )
    
    /// 지정된 간격을 가지는 수직 레이아웃 생성
    /// - Parameter spacing: 아이템 사이 간격 (기본값: 0.0)
    public static func vertical(spacing: CGFloat) -> Self {
        .init(spec: .vertical(spacing: spacing))
    }
    
    /// 수평 레이아웃 생성
    /// - Parameters:
    ///   - spacing: 아이템 사이 간격 (기본값: 0.0)
    ///   - scrollingBehavior: 스크롤 동작 (기본값: .continuous)
    public static func horizontal(
        spacing: CGFloat,
        scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
    ) -> Self {
        .init(spec: .horizontal(
            spacing: spacing,
            scrollingBehavior: scrollingBehavior)
        )
    }
    
    /// 수직 그리드 레이아웃 생성
    /// - Parameters:
    ///   - numberOfItemsInRow: 한 줄에 들어갈 아이템 개수
    ///   - itemSpacing: 아이템 간 간격
    ///   - lineSpacing: 줄 간 간격
    public static func verticalGrid(
        numberOfItemsInRow: Int,
        itemSpacing: CGFloat,
        lineSpacing: CGFloat
    ) -> Self {
        .init(spec: .verticalGrid(
            numberOfItemsInRow: numberOfItemsInRow,
            itemSpacing: itemSpacing,
            lineSpacing: lineSpacing)
        )
    }
}

extension DefaultCompositionalLayoutSectionFactory {
    /// spec에 따라 실제 section layout 생성
    public func makeSectionLayout() -> SectionLayout? {
        switch spec {
            
        /// 세로 레이아웃
        case .vertical(let spacing):
            return VerticalLayout(spacing: spacing)
                .insets(sectionContentInsets)
                .headerPinToVisibleBounds(headerPinToVisibleBounds)
                .footerPinToVisibleBounds(footerPinToVisibleBounds)
                .withVisibleItemsInvalidationHandler(visibleItemsInvalidationHandler)
                .makeSectionLayout()
            
        /// 가로 레이아웃
        case .horizontal(let spacing, let scrollingBehavior):
            return HorizontalLayout(
                spacing: spacing,
                scrollingBehavior: scrollingBehavior
            )
            .insets(sectionContentInsets)
            .headerPinToVisibleBounds(headerPinToVisibleBounds)
            .footerPinToVisibleBounds(footerPinToVisibleBounds)
            .withVisibleItemsInvalidationHandler(visibleItemsInvalidationHandler)
            .makeSectionLayout()
            
        /// 세로 그리드 레이아웃
        case .verticalGrid(let numberOfItemsInRow, let itemSpacing, let lineSpacing):
            return VerticalGridLayout(
                numberOfItemsInRow: numberOfItemsInRow,
                itemSpacing: itemSpacing,
                lineSpacing: lineSpacing
            )
            .insets(sectionContentInsets)
            .headerPinToVisibleBounds(headerPinToVisibleBounds)
            .footerPinToVisibleBounds(footerPinToVisibleBounds)
            .withVisibleItemsInvalidationHandler(visibleItemsInvalidationHandler)
            .makeSectionLayout()
        }
    }
}

// MARK: - Modifier
extension DefaultCompositionalLayoutSectionFactory {
    
    /// section의 inset을 설정합니다.
    ///
    /// - Parameters:
    ///   - insets: section에 적용할 inset 값
    public func withSectionContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        var copy = self
        copy.sectionContentInsets = insets
        return copy
    }
    
    /// header가 화면 상단에 고정될지 여부를 설정합니다.
    ///
    /// - Parameters:
    ///   - pinToVisibleBounds: header를 상단에 고정할지 여부
    public func withHeaderPinToVisibleBounds(_ pinToVisibleBounds: Bool) -> Self {
        var copy = self
        copy.headerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }

    /// footer가 화면 하단에 고정될지 여부를 설정합니다.
    ///
    /// - Parameters:
    ///   - pinToVisibleBounds: footer를 하단에 고정할지 여부
    public func withFooterPinToVisibleBounds(_ pinToVisibleBounds: Bool) -> Self {
        var copy = self
        copy.footerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// visible item이 변경될 때 호출되는 핸들러를 설정합니다.
    ///
    /// - Parameters:
    ///   - handler: visible item invalidation handler
    public func withVisibleItemsInvalidationHandler(
        _ visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    ) -> Self {
        var copy = self
        copy.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        return copy
    }
}
