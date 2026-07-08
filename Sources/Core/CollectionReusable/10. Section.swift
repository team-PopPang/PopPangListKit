//
//  Section.swift
//  PopPangListKitTests
//
//  Created by 김동현 on 7/7/26.
//

import UIKit
import DifferenceKit

/// `Section`은 UICollectionView의 Section을 표현하는 구조체입니다.
///
/// Section은 셀 배열, 헤더, 푸터 등
/// 실제 UI의 Section 계층 구조와 유사한 데이터 구조를 가집니다.
/// 즉, UI를 직접 만드는 것이 아니라
/// "Section UI를 표현하기 위한 데이터"를 구성하는 역할입니다.
///
/// - Note: 실제 레이아웃은 NSCollectionLayoutSection에 의해 결정되며,
/// 반드시 withSectionLayout modifier를 통해 설정해야 합니다.
public struct Section: Identifiable {
    
    /// Section을 식별하기 위한 ID
    public let id: AnyHashable
    public var header: SupplementaryView?
    public var cells: [Cell]
    public var footer: SupplementaryView?
    
    /// Section 레이아웃 설정(타입 소거된 레이아웃 클로저)
    private var sectionLayout: CompositionalLayoutSectionFactory.SectionLayout?
    
    /// Section을 생성하는 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///  - id: Section을 식별하는 식별자
    ///  - cells: 화면에 표시될 셀 배열
    public init(
        id: some Hashable,
        cells: [Cell]
    ) {
        self.id = id
        self.cells = cells
    }
}

// MARK: - Layout / Header, Footer
extension Section {
    
    /// Section의 레이아웃을 지정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - sectionLayout: 커스텀 section layout을 제공하는 클로저
    public func withSectionLayout(
        _ sectionLayout: CompositionalLayoutSectionFactory.SectionLayout?
    ) -> Self {
        var copy = self
        copy.sectionLayout = sectionLayout
        return copy
    }

    // MARK: - Todo: DefaultCompositionalLayoutSectionFactory
    
    /// Section의 Header를 설정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - headerComponent: 헤더가 표현할 컴포넌트
    ///  - alignment: 컴포넌트의 정렬 방식
    public func withHeader(
        _ headerComponent: some Component,
        alignment: NSRectAlignment = .top
    ) -> Self {
        var copy = self
        copy.header = .init(
            kind: UICollectionView.elementKindSectionHeader,
            component: headerComponent,
            alignment: alignment
        )
        return copy
    }
    
    /// Section의 Footer를 설정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - footerComponent: 푸터가 표현할 컴포넌트
    ///  - alignment: 컴포넌트의 정렬 방식
    public func withFooter(
        _ footerComponent: some Component,
        alignment: NSRectAlignment = .top
    ) -> Self {
        var copy = self
        copy.footer = .init(
            kind: UICollectionView.elementKindSectionFooter,
            component: footerComponent,
            alignment: alignment
        )
        return copy
    }
    
    /// 실제 NSCollectionLayoutSection을 생성하는 내부 메서드
    func layout(
        index: Int,
        enviroment: NSCollectionLayoutEnvironment,
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutSection? {
        
        /// 레이아웃이 없으면 에러 발생
        if sectionLayout == nil {
            assertionFailure("반드시 Section Layout을 설정해야 합니다.")
        }
        
        /// 클로저 설정 -> 실제 레이아웃 생성
        return sectionLayout?((self, index, enviroment, sizeStorage))
    }
}

// MARK: - Todo: Event Handler

// MARK: - Hashable
extension Section: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id && lhs.header == rhs.header && lhs.footer == rhs.footer
    }
}

// MARK: - DifferentiableSection
extension Section: DifferentiableSection {
    
    /// diff 계산 시 Section을 식별하기 위한 고유 ID
    ///
    /// DifferenceKit에서 "같은 Section인지" 판단할 때 사용된다.
    /// 여기서는 Section의 id를 그대로 사용한다.
    public var differenceIdentifier: AnyHashable {
        id
    }
    
    /// Section이 가지고 있는 요소들 (셀 목록)
    ///
    /// diff 계산 시 비교 대상이 되는 실제 데이터이다.
    public var elements: [Cell] {
        cells
    }
    
    /// 기존 Section을 기반으로 새로운 Section을 생성하는 초기화 메서드
    ///
    /// diff 과정에서 변경된 elements를 반영하기 위해 사용된다.
    ///
    /// - Parameters:
    ///   - source: 기존 Section
    ///   - cells: 변경된 Cell 컬렉션
    public init(
        source: Section,
        elements cells: some Swift.Collection<Cell>
    ) {
        self = source
        self.cells = Array(cells)
    }
    
    /// 두 Section의 내용이 동일한지 비교
    ///
    /// differenceIdentifier가 같더라도,
    /// 실제 내용이 변경되었는지 판단하기 위해 사용된다.
    ///
    /// - Parameter source: 비교 대상 Section
    /// - Returns: 내용이 동일하면 true
    public func isContentEqual(to source: Section) -> Bool {
        self == source
    }
}
