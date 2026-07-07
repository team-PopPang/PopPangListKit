//
//  AnyComponent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

/*
 AnyComponentBox는 실제 Component를 감싸고,
 ComponentBox는 그 박스들을 같은 타입처럼 다루게 하고,
 AnyComponent는 밖에서 쓰는 최종 포장지.
 */

/// Component.item만 따로 꺼내서 Equatable 비교용으로 감싼 타입
public struct AnyItem: Equatable {
    
    private let baseItem: any Equatable
    
    init(component: some Component) {
        self.baseItem = component.item
    }
    
    public static func == (lhs: AnyItem, rhs: AnyItem) -> Bool {
        lhs.baseItem.isEqual(rhs.baseItem)
    }
}

/// AnyComponent가 실제 Component 타입을 몰라도 render, layout, item 같은 기능을 호출하게 해주는 내부 공통 약속
/// 여러 AnyComponentBox를 같은 타입처럼 다루기 위한 약속
private protocol ComponentBox {
    associatedtype Base: Component
    
    var baseComponent: Base { get }
    var reuseIdentifier: String { get }
    var layoutMode: ContentLayoutMode { get }
    var item: Base.Item { get }
    
    @MainActor func renderContent(coordinator: Any) -> UIView
    @MainActor func render(in content: UIView, coordinator: Any)
    @MainActor func layout(content: UIView, in container: UIView)
    @MainActor func makeCoordinator() -> Any
}

/// ProfileComponent, BannerComponent 같은 진짜 Component 하나를 실제로 보관하고 실행하는 박스
private struct AnyComponentBox<Base: Component>: ComponentBox {
    
    let baseComponent: Base
    
    var item: Base.Item {
        baseComponent.item
    }
    
    var reuseIdentifier: String {
        baseComponent.reuseIdentifier
    }
    
    var layoutMode: ContentLayoutMode {
        baseComponent.layoutMode
    }
    
    init(baseComponent: Base) {
        self.baseComponent = baseComponent
    }
    
    @MainActor
    func renderContent(coordinator: Any) -> UIView {
        baseComponent.renderContent(coordinator: coordinator as! Base.Coordinator)
    }
    
    @MainActor
    func render(in content: UIView, coordinator: Any) {
        guard let content = content as? Base.Content,
              let coordinator = coordinator as? Base.Coordinator else {
            return
        }
        baseComponent.render(in: content, coordinator: coordinator)
    }
    
    @MainActor
    func layout(content: UIView, in container: UIView) {
        guard let content = content as? Base.Content else { return }
        baseComponent.layout(content: content, in: container)
    }
    
    @MainActor
    func makeCoordinator() -> Any {
        baseComponent.makeCoordinator()
    }
}

/// 서로 다른 Component들을 [AnyComponent] 배열에 담을 수 있게 해주는 외부용 타입 소거 래퍼
public struct AnyComponent: Component, Equatable {
    
    private let box: any ComponentBox
    
    private var baseComponent: any Component {
        box.baseComponent
    }
    
    public var layoutMode: ContentLayoutMode {
        box.layoutMode
    }
    
    public var reuseIdentifier: String {
        box.reuseIdentifier
    }
    
    public var item: AnyItem {
        AnyItem(component: box.baseComponent)
    }
    
    @MainActor
    public func renderContent(coordinator: Any) -> UIView {
        box.renderContent(coordinator: coordinator)
    }
    
    @MainActor
    public func render(in content: UIView, coordinator: Any) {
        box.render(in: content, coordinator: coordinator)
    }
    
    @MainActor
    public func layout(content: UIView, in container: UIView) {
        box.layout(content: content, in: container)
    }
    
    /// 내부 `Component`를 특정 타입으로 다운캐스팅 시도
    ///
    /// - Parameter _: 변환할 타입
    /// - Returns: 성공하면 해당 타입, 실패하면 nil
    public func `as`<T>(_: T.Type) -> T? {
        box.baseComponent as? T
    }
    
    @MainActor
    public func makeCoordinator() -> Any {
        box.makeCoordinator()
    }
    
    public static func == (lhs: AnyComponent, rhs: AnyComponent) -> Bool {
        lhs.item == rhs.item
    }
}
