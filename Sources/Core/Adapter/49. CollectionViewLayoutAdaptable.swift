//
//  CollectionViewLayoutAdaptable.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/23/26.
//

import UIKit

/// List에서 데이터와 사이즈 정보를 관리하기 위한 프로토콜
///
/// 데이터 소스 객체는 컬렉션뷰의 데이터를 관리한다.
/// 또한 셀 / supplementary view의 사이즈 정보를 캐싱하고 관리할 수 있어야 한다.
///
/// - Note:
/// `CollectionViewAdapter`가 이 프로토콜을 채택하여 내부적으로 데이터와 사이즈를 관리하므로,
/// 일반적으로 직접 구현할 필요는 없다.
public protocol CollectionViewLayoutAdapterDataSource: AnyObject {
    
    /// 특정 index에 해당하는 Section을 반환한다
    /// - Parameter index: 가져올 Section의 index
    /// - Returns: 해당 index의 Section
    func sectionItem(at index: Int) -> Section?
    
    /// 캐싱된 사이즈 정보를 관리하는 ComponentSizeStorage를 반환한다
    /// - Returns: 사이즈 캐시를 관리하는 ComponentSizeStorage
    func sizeStorage() -> ComponentSizeStorage
}

/// `CollectionViewLayoutAdaptable`은
/// UICollectionViewCompositionalLayout과 ListKit 레이아웃 로직 사이를 연결하는 어댑터 인터페이스이다.
///
/// UICollectionViewCompositionalLayout의 sectionProvider는
/// 이 인터페이스의 sectionLayout 메서드와 매핑된다.
///
/// 즉, sectionLayout을 구현하면 CompositionalLayout을 구성할 수 있다.
///
/// - Note:
/// `CollectionViewLayoutAdapter`가 이 프로토콜을 구현하고 있으므로,
/// 일반적으로 직접 구현할 필요는 없다.
public protocol CollectionViewLayoutAdaptable: AnyObject {
    
    /// NSCollectionLayoutSection 생성을 위한 데이터 소스
    var dataSource: CollectionViewLayoutAdapterDataSource? { get set }
    
    /// NSCollectionLayoutSection을 생성하는 메서드
    /// - Parameters:
    ///   - index: 생성할 Section의 index
    ///   - environment: 현재 레이아웃 환경 정보
    /// - Returns: 생성된 NSCollectionLayoutSection
    func sectionLayout(
        index: Int,
        enviroment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection?
}

/// CollectionViewLayoutAdaptable의 기본 구현 클래스
///
/// UICollectionView 초기화 시 CollectionViewLayoutAdaptable을 바로 주입할 수 있도록 확장되어 있다.
///
/// 만약 UICollectionViewCompositionalLayout을 직접 주입하고 싶다면 아래와 같이 사용 가능:
///
/// ```swift
/// UICollectionView(
///   frame: .zero,
///   collectionViewLayout: UICollectionViewCompositionalLayout(
///     sectionProvider: layoutAdapter.sectionLayout
///   )
/// )
/// ```
@MainActor
public class CollectionViewLayoutAdapter: @MainActor CollectionViewLayoutAdaptable {
    
    /// NSCollectionLayoutSection 생성을 위한 데이터 소스
    public weak var dataSource: CollectionViewLayoutAdapterDataSource?
    
    public init() {}
    
    /// NSCollectionLayoutSection을 생성하는 메서드
    /// - Parameters:
    ///   - index: 생성할 Section의 index
    ///   - environment: 레이아웃 환경 정보
    /// - Returns: 생성된 NSCollectionLayoutSection
    public func sectionLayout(
        index: Int,
        enviroment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        
        // 데이터 소스 없으면 생성 불가
        guard let dataSource else {
            return nil
        }
        
        // 해당 Section이 없거나, 셀이 비어있으면 생성 안 함
        guard let sectionItem = dataSource.sectionItem(at: index),
              !sectionItem.cells.isEmpty else {
            return nil
        }
        
        // Section이 가지고 있는 layout 로직으로 실제 NSCollectionLayoutSection 생성
        return sectionItem.layout(
            index: index,
            enviroment: enviroment,
            sizeStorage: dataSource.sizeStorage()
        )
    }
}
