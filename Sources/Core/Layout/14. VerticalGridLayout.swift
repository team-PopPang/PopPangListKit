//
//  VerticalGridLayout.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 이 레이아웃은 "그리드 형태의 세로 스크롤"을 지원합니다.
///
/// 한 줄에 몇 개의 셀을 보여줄지 지정하면,
/// 그리드 형태 UI를 쉽게 구현할 수 있습니다.
/// - Note: 세로 그리드 레이아웃을 사용할 때는
///         컴포넌트의 레이아웃 모드가 Flexible Height여야 합니다.
@MainActor
public struct VerticalGridLayout: @MainActor CompositionalLayoutSectionFactory {
    
    /// 한 줄(row)에 들어갈 아이템 개수
    public let numberOfItemsInRow: Int
    
    /// 아이템 간 가로 간격
    private let itemSpacing: CGFloat
    
    /// 줄(line) 간 세로 간격
    private let lineSpacing: CGFloat
    
    /// 섹션 전체 여백
    private var sectionInsets: NSDirectionalEdgeInsets?
    
    /// 헤더를 상단에 고정할지 여부
    private var headerPinToVisibleBounds: Bool?
    
    /// 푸터를 상단에 고정할지 여부
    private var footerPinToVisibleBounds: Bool?
    
    /// visible item 변경 시 호출되는 핸들러
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    
    /// 새로운 세로 그리드 레이아웃을 초기화합니다.
    /// - Parameters:
    ///   - numberOfItemsInRow: 한 줄에 들어갈 아이템 개수
    ///   - itemSpacing: 아이템 간 간격
    ///   - lineSpacing: 줄 간 간격
    public init(
        numberOfItemsInRow: Int,
        itemSpacing: CGFloat,
        lineSpacing: CGFloat
    ) {
        self.numberOfItemsInRow = numberOfItemsInRow
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
    }
    
    /// 섹션 레이아웃을 생성합니다.
    public func makeSectionLayout() -> SectionLayout? {
        { context -> NSCollectionLayoutSection? in
            
            /// 전체 높이를 계산하기 위한 변수
            var verticalGroupHeight: CGFloat = 0
            
            /// cells를 "한 줄씩" 잘라서(chunk)
            /// 각각 horizontal 그룹으로 만든다
            let horizontalGroups = context.section.cells
                .chunks(ofCount: numberOfItemsInRow)
                .map { chunkedCells in
                    
                    /// 해당 줄에서 가장 큰 height를 기준으로 줄 높이를 결정
                    let horizontalGroupHeight = layoutCellItems(
                        cells: Array(chunkedCells),
                        sizeStorage: context.sizeStorage
                    )
                    .max { layout1, layout2 in
                        layout1.layoutSize.heightDimension.dimension <
                        layout1.layoutSize.heightDimension.dimension
                    }?.layoutSize.heightDimension
                    ?? .estimated(context.environment.container.contentSize.height)
                    
                    /// 전체 높이에 누적
                    verticalGroupHeight += horizontalGroupHeight.dimension
                    
                    /// 가로 그룹 생성(한 줄)
                    let layoutGroup = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: horizontalGroupHeight
                        ),
                        subitem: NSCollectionLayoutItem(
                            layoutSize: .init(
                                /// 각 아이템은 동일한 비율로 나눈다
                                widthDimension: .fractionalWidth(1.0 / CGFloat(numberOfItemsInRow)),
                                heightDimension: horizontalGroupHeight
                            )
                        ),
                        count: numberOfItemsInRow
                    )
                    
                    /// 아이템 간 간격
                    layoutGroup.interItemSpacing = .fixed(itemSpacing)
                    
                    return layoutGroup
                }
            
            /// 여러 줄을 묶어서 "세로 그룹" 생성
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(verticalGroupHeight)
                ),
                subitems: horizontalGroups
            )
            
            /// 줄 간 간격
            group.interItemSpacing = .fixed(itemSpacing)
            
            /// 섹션 설정
            let section = NSCollectionLayoutSection(group: group)
            
            /// 섹션 Inset 적용
            if let sectionInsets {
                section.contentInsets = sectionInsets
            }
            
            /// 스크롤 시 visible item 변경 핸들러
            if let visibleItemsInvalidationHandler {
                section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
            }
            
            /// 헤더 설정
            let headerItem = layoutHeaderItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            if let headerPinToVisibleBounds {
                headerItem?.pinToVisibleBounds = headerPinToVisibleBounds
            }
            
            /// 푸터 설정
            let footerItem = layoutFooterItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            if let footerPinToVisibleBounds {
                footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
            }
            
            /// 헤더 + 푸터 등록
            section.boundarySupplementaryItems = [
                headerItem,
                footerItem
            ].compactMap { $0 }
            
            return section
        }
    }
}

// MARK: - Modifier
extension VerticalGridLayout {
    
    /// 섹션 여백 설정
    public func insets(_ insets: NSDirectionalEdgeInsets?) -> Self {
        var copy = self
        copy.sectionInsets = insets
        return copy
    }
    
    /// 헤더 고정 여부 설정
    public func headerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.headerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// 푸터 고정 여부 설정
    public func footerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.footerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// visible item invalidation handler 설정
    public func withVisibleItemsInvalidationHandler(
        _ handler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    ) -> Self {
        var copy = self
        copy.visibleItemsInvalidationHandler = handler
        return copy
    }
}
