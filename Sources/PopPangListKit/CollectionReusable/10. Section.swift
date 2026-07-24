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
public struct Section: Identifiable, @MainActor ListingViewEventHandler {
    
    /// Section을 식별하기 위한 ID
    public let id: AnyHashable
    
    /// 헤더를 표현하는 SuplementaryView
    public var header: SupplementaryView?
    
    /// UICollectionViewCell을 표현하는 Cell 배열
    public var cells: [Cell] {
        get {
            scopedCells
        }
        set {
            scopedCells = Self.prepareCells(newValue, sectionID: id)
        }
    }

    /// Section 범위의 내부 identity가 적용된 Cell 배열
    private var scopedCells: [Cell]
    
    /// 푸터를 사용하는 SuplementaryView
    public var footer: SupplementaryView?
    
    /// Section 레이아웃 설정(타입 소거된 레이아웃 클로저)
    private var sectionLayout: CompositionalLayoutSectionFactory.SectionLayout?

    /// 기존 Section 내부 변경을 애니메이션 없이 적용할지 여부
    ///
    /// diff identity나 content equality에는 포함하지 않고,
    /// CollectionViewAdapter의 update transaction을 나누는 정책으로만 사용합니다.
    var isUpdateAnimationDisabled = false
    
    /// 이벤트 저장소 (header/footer lifecycle 이벤트 등)
    let eventStorage: ListingViewEventStorage
    
    /// Section을 생성하는 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///  - id: Section을 식별하는 식별자
    ///  - cells: 화면에 표시될 셀 배열
    public init(
        id: some Hashable,
        cells: [Cell]
    ) {
        let sectionID = AnyHashable(id)
        self.id = sectionID
        self.scopedCells = Self.prepareCells(cells, sectionID: sectionID)
        self.eventStorage = ListingViewEventStorage()
    }
    
    /// Section을 생성하는 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///  - id: Section을 식별하는 식별자
    ///  - cells: 화면에 표시될 셀 배열을 생성하는 Builder
    public init(
        id: some Hashable,
        @CellsBuilder _ cells: () -> [Cell]
    ) {
        let sectionID = AnyHashable(id)
        self.id = sectionID
        self.scopedCells = Self.prepareCells(cells(), sectionID: sectionID)
        self.eventStorage = ListingViewEventStorage()
    }
}

extension Section {

    /// 이 Section 내부의 업데이트 애니메이션을 비활성화합니다.
    ///
    /// 리스트 전체 update strategy가 `.animatedBatchUpdates`일 때,
    /// 기존 snapshot에도 존재하는 같은 ID의 Section 내부 변경을
    /// non-animated batch update로 먼저 적용합니다.
    ///
    /// Section 자체의 삽입, 삭제, 이동은 리스트 전체 update strategy를 따릅니다.
    ///
    /// - Parameter disabled: `true`면 업데이트 애니메이션을 비활성화합니다.
    /// - Returns: Section 단위 애니메이션 정책이 적용된 새로운 `Section`
    @MainActor
    public func disablesUpdateAnimation(_ disabled: Bool = true) -> Self {
        var copy = self
        copy.isUpdateAnimationDisabled = disabled
        return copy
    }

    /// 같은 Section 내부에서 중복된 raw Cell ID를 선언하지 못하도록 검사하고,
    /// 모든 Cell에 Section 범위의 내부 identity를 적용합니다.
    private static func prepareCells(
        _ cells: [Cell],
        sectionID: AnyHashable
    ) -> [Cell] {
        #if DEBUG
        let duplicateIDs = duplicateCellIDs(in: cells)

        assert(
            duplicateIDs.isEmpty,
            """
            Duplicate Cell ID(s) \(duplicateIDs) in Section '\(sectionID)'. \
            Cell IDs must be unique within a Section; \
            the same Cell ID may be reused in different Sections.
            """
        )
        #endif

        return cells.map {
            $0.scoped(to: sectionID)
        }
    }

    /// Debug assertion과 테스트가 같은 중복 판정 규칙을 공유하도록 분리합니다.
    static func duplicateCellIDs(in cells: [Cell]) -> [AnyHashable] {
        var seenIDs = Set<AnyHashable>()
        var duplicateIDs = Set<AnyHashable>()

        for cell in cells where seenIDs.insert(cell.id).inserted == false {
            duplicateIDs.insert(cell.id)
        }

        return duplicateIDs.sorted {
            String(reflecting: $0) < String(reflecting: $1)
        }
    }
}

// MARK: - Layout / Header, Footer
extension Section {
    
    /// Section의 레이아웃을 지정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - sectionLayout: 커스텀 section layout을 제공하는 클로저
    @MainActor
    public func withSectionLayout(
        _ sectionLayout: CompositionalLayoutSectionFactory.SectionLayout?
    ) -> Self {
        var copy = self
        copy.sectionLayout = sectionLayout
        return copy
    }
    
    /// Section의 레이아웃을 설정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - layoutMaker: NSCollectionLayoutSection을 생성하는 factory 객체
    @MainActor
    public func withSectionLayout(
        _ layoutMaker: CompositionalLayoutSectionFactory
    ) -> Self {
        var copy = self
        copy.sectionLayout = layoutMaker.makeSectionLayout()
        return copy
    }
    
    /// Section의 레이아웃을 설정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - defaultLayoutMaker: 프레임워크에서 제공하는 기본 레이아웃 factory
    @MainActor
    public func withSectionLayout(
        _ defaultLayoutMaker: DefaultCompositionalLayoutSectionFactory
    ) -> Self {
        var copy = self
        copy.sectionLayout = defaultLayoutMaker.makeSectionLayout()
        return copy
    }

    // MARK: - Todo: DefaultCompositionalLayoutSectionFactory
    
    /// Section의 Header를 설정하는 modifier입니다.
    ///
    /// - Parameters:
    ///  - headerComponent: 헤더가 표현할 컴포넌트
    ///  - alignment: 컴포넌트의 정렬 방식
    @MainActor
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
    @MainActor
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
    @MainActor
    func layout(
        index: Int,
        environment: NSCollectionLayoutEnvironment,
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutSection? {
        
        /// 레이아웃이 없으면 에러 발생
        if sectionLayout == nil {
            assertionFailure("반드시 Section Layout을 설정해야 합니다.")
        }
        
        /// 클로저 설정 -> 실제 레이아웃 생성
        return sectionLayout?((self, index, environment, sizeStorage))
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

// MARK: - Event Handler
extension Section {
    
    /// Header가 화면에 표시될 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///   - handler: Header가 화면에 표시될 때 호출되는 콜백 핸들러
    @MainActor
    @discardableResult
    public func willDisplayHeader(
        _ handler: @escaping (WillDisplayEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        if header == nil {
            assertionFailure("Please declare the header first using [withHeader]")
        }
        copy.header = header?.willDisplay(handler)
        return copy
    }
    
    /// Footer가 화면에 표시될 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///   - handler: Footer가 화면에 표시될 때 호출되는 콜백 핸들러
    @MainActor
    @discardableResult
    public func willDisplayFooter(
        _ handler: @escaping (WillDisplayEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        if footer == nil {
            assertionFailure("Please declare the footer first using [withFooter]")
        }
        copy.footer = footer?.willDisplay(handler)
        return copy
    }
    
    /// Header가 화면에서 제거될 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: Header가 화면에서 제거될 때 호출되는 콜백 핸들러
    @MainActor
    public func didEndDisplayHeader(
        _ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        if header == nil {
          assertionFailure("Please declare the header first using [withHeader]")
        }
        copy.header = header?.didEndDisplaying(handler)
        return copy
    }
    
    /// Footer가 화면에서 제거될 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: Footer가 화면에서 제거될 때 호출되는 콜백 핸들러
    @MainActor
    public func didEndDisplayFooter(
        _ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        if footer == nil {
            assertionFailure("Please declare the footer first using [withFooter]")
        }
        copy.footer = footer?.didEndDisplaying(handler)
        return copy
    }
}
