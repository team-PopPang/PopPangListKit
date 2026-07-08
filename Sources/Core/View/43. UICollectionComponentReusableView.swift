//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/**
 estimated size
 ↓
 UICollectionView가 reusable view에게 최종 크기 물어봄
 ↓
 preferredLayoutAttributesFitting 호출
 ↓
 renderedContent.sizeThatFits(...)로 실제 크기 계산
 ↓
 attributes.frame.size = size
 ↓
 최종 크기 반영
 */
/// UICollectionReusableView를 기반으로 Component를 렌더링하기 위한 커스텀 뷰입니다.
/// Component → UIView로 렌더링 → UICollectionReusableView에 올림
public final class UICollectionComponentReusableView: UICollectionReusableView, ComponentRenderable {
    
    /// 실제 렌더링된 UIView 콘텐츠
    var renderedContent: UIView?
    
    /// Component에서 사용하는 코디네이터 (타입 소거)
    var coordinator: Any?
    
    /// 렌더링된 Component (타입 소거된 형태)
    var renderedComponent: AnyComponent?
    
    /// 사이즈가 변경되었을 때 호출되는 콜백
    var onSizeChanged: ((CGSize) -> Void)?
    
    /// 이전 bounds 크기를 저장 (사이즈 캐싱 비교용)
    private var previousBounds: CGSize = .zero
    
    /// storyboard/xib 사용 방지
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 기본 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    // MARK: - Override Methods
    /// trait(다크모드, 폰트 등)이 변경될 때 호출됨
    public override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        /// 사이즈를 다시 계산해야 하는 상황이면
        /// 이전 사이즈 초기화 (캐시 무효화)
        if shouldInvalidateContentSize(
          previousTraitCollection: previousTraitCollection
        ) {
          previousBounds = .zero
        }
    }
    
    /// 재사용될 때 호출됨
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        /// 이전 사이즈 초기화(재사용 시 캐시 리셋)
        previousBounds = .zero
    }
    
    /// 레이아웃 변경 시 호출됨
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 현재 bounds 저장 (다음 비교용)
        previousBounds = bounds.size
    }
    
    /// AutoLayout / CompositionalLayout에서 셀 사이즈 계산 시 호출됨
    /// 컴포넌트가 AutoLayout일 수도, 아닐 수도 있어서 시스템의 기본 사이즈 계산을 신뢰할 수 없기 때문에, sizeThatFits를 사용해 실제 필요한 크기를 직접 계산해서 최종 사이즈를 정확하게 결정하려고 override 한다
    public override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
    
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        /// 렌더링된 콘텐츠가 없으면 그대로 반환
        guard let renderedContent else {
            return attributes
        }
        
        /// FeatureFlag 활성화 + 이전 사이즈와 동일하면
        /// 다시 계산하지 않고 그대로 사용 (캐싱)
        if ListKitFeatureFlag.provider.isEnabled(for: .useCachedViewSize),
           previousBounds == attributes.size {
            return attributes
        }
        
        /// 콘텐츠에 맞는 사이즈 계산
        let size = renderedContent.sizeThatFits(bounds.size)
        
        /// Component가 있다면 사이즈 변경 콜백 호출
        if renderedComponent != nil {
            onSizeChanged?(size)
        }
        
        /// 계산된 사이즈 적용
        attributes.frame.size = size
        return attributes
    }
}
