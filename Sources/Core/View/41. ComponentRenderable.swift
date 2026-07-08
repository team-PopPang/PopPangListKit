//
//  ComponentRenderable.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// Component를 렌더링할 수 있는 객체를 정의하는 프로토콜입니다.
protocol ComponentRenderable: AnyObject {
    
    /// Component가 추가될 컨테이너 뷰
    var componentContainerView: UIView { get }
    
    /// 실제 렌더링된 콘텐츠 뷰
    var renderedContent: UIView? { get set }
    
    /// Component에서 사용하는 코디네이터 (타입 소거)
    var coordinator: Any? { get set }
    
    /// 현재 렌더링된 Component ( 타입 소거)
    var renderedComponent: AnyComponent? { get set }
    
    /// Component를 렌더링하는 함수
    @MainActor
    func render(component: AnyComponent)
}

// MARK: - Default 구현
/// UICollectionViewCell일 경우
/// contentView를 컨테이너로 사용
extension ComponentRenderable where Self: UICollectionViewCell {
    var componentContainerView: UIView {
        contentView
    }
}

/// UICollectionReusableView일 경우
/// 자기 자신을 컨테이너로 사용
extension ComponentRenderable where Self: UICollectionReusableView {
    var componentContainerView: UIView {
        self
    }
}

/// UIView 기반에서의 기본 렌더링 로직
extension ComponentRenderable where Self: UIView {
    
    @MainActor
    func render(component: AnyComponent) {
        
        /// 이미 렌더링된 콘텐츠가 있는 경우
        if let renderedContent {
            
            /// 기존 뷰에 Component를 다시 그리기 (업데이트)
            component.render(in: renderedContent, coordinator: coordinator ?? ())
            
            /// 현재 Component 저장
            renderedComponent = component
        } else {
            
            /// 최초 렌더링: coordinator 생성
            coordinator = component.makeCoordinator()
            
            /// 콘텐츠 뷰 생성
            let content = component.renderContent(coordinator: coordinator ?? ())
            
            /// 컨테이너에 레이아웃 적용
            component.layout(content: content, in: componentContainerView)
            
            /// 렌더링된 콘텐츠 저장
            renderedContent = content
            
            /// 재귀 호출 -> 업데이트 로직 실행
            render(component: component)
        }
    }
}
