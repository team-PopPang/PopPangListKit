//
//  UICollectionViewComponentCell.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit
import Combine

public final class UICollectionViewComponentCell: UICollectionViewCell, ComponentRenderable {
    
    /// 실제 렌더링된 UIView (Component → UIView 결과)
    public internal(set) var renderedContent: UIView?
    
    /// Component에서 사용하는 coordinator (이벤트, 상태 관리용)
    var coordinator: Any?
    
    /// 현재 렌더링된 Component
    var renderedComponent: AnyComponent?
    
    /// Combine 구독을 관리하기 위한 cancellable 배열
    var cancellables: [AnyCancellable]?
    
    /// 사이즈 변경 시 외부로 전달하는 콜백
    var onSizeChanged: ((CGSize) -> Void)?
    
    /// 이전 bounds (사이즈 캐싱용)
    private var previousBounds: CGSize = .zero
    
    /// 기본 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    /// storyboard 사용 금지
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 메모리 해제 시 Combine 구독 정리
    deinit {
        cancellables?.forEach { $0.cancel() }
    }
    
    // MARK: - Override Methods
    /// trait 변화 시 (다이나믹 폰트, size class 등)
    /// 사이즈가 다시 계산되어야 하면 캐시 초기화
    public override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if shouldInvalidateContentSize(
            previousTraitCollection: previousTraitCollection
        ) {
            previousBounds = .zero
        }
    }
    
    /// 셀 재사용 시 상태 초기화
    public override func prepareForReuse() {
        super.prepareForReuse()
        previousBounds = .zero
        cancellables?.forEach { $0.cancel() }
        cancellables = nil
    }
    
    /// 레이아웃 완료 후 현재 사이즈 저장 (캐싱용)
    public override func layoutSubviews() {
        super.layoutSubviews()
        previousBounds = bounds.size
    }
    
    /// 컬렉션뷰가 셀의 최종 사이즈를 물어볼 때 호출되는 메서드
    /// 여기서 Component 기반으로 실제 사이즈를 계산하여 반환한다
    public override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        /**
         https://channel.io/ko/team/blog/articles/iOS-%EC%B1%84%ED%8C%85-%EB%A6%AC%ED%8C%A9%ED%86%A0%EB%A7%81%EC%9C%BC%EB%A1%9C-%EC%95%88%EC%A0%95%EC%84%B1%EA%B3%BC-%EC%84%B1%EB%8A%A5-%EA%B0%9C%EC%84%A0%ED%95%98%EA%B8%B0-7585cc77
         1. 시스템: "100 정도?"
         2. override 실행
         3. sizeThatFits → 180 계산
         4. attributes.size = 180
         5. previousBounds = 180
         
         1. 시스템: "또 180 줄게" (이미 layout 반영됨)
         2. previousBounds == attributes.size → true
         3. 계산 생략
         */
        
        // 시스템 기본 계산 먼저 수행
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // 렌더링된 컨텐츠가 없으면 기본값 반환
        guard let renderedContent else {
            return attributes
        }
        
        // 캐시 기능이 활성화되어 있고, 이전 사이즈와 동일하면 재계산 생략
        if ListKitFeatureFlag.provider.isEnabled(for: .useCachedViewSize),
           previousBounds == attributes.size {
            return attributes
        }
        
        // 핵심: UIView의 sizeThatFits를 사용해 실제 필요한 사이즈 계산
        let size = renderedContent.sizeThatFits(contentView.bounds.size)
        
        // Componet가 존재하면 사이즈 변경 콜백 호출
        if renderedComponent != nil {
            onSizeChanged?(size)
        }
        
        // 계산된 사이즈를 최종 attributes에 반영
        attributes.frame.size = size
        
        return attributes
    }
}
