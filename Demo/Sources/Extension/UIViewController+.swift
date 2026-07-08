//
//  UIViewController+.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import SwiftUI

/*
 // SwiftUI가 필요할 때 ViewController 생성을 관리할 수 있다
 // UIViewController 인스턴스를 미리 만들어서 들고 있는 것보다 안전하다
 struct ContentView: View {
     var body: some View {
         ViewControllerRepresentable {
             MyViewController()
         }
     }
 }
 */
public struct ViewControllerRepresentable<
    VC: UIViewController
>: UIViewControllerRepresentable {
    
    public let makeViewController: () -> VC
    public let update: (VC) -> Void
    
    public init(
        makeViewController: @escaping () -> VC,
        update: @escaping (VC) -> Void = { _ in }
    ) {
        self.makeViewController = makeViewController
        self.update = update
    }

    public func makeUIViewController(
        context: Context
    ) -> VC {
        makeViewController()
    }
    
    public func updateUIViewController(
        _ uiViewController: VC,
        context: Context
    ) {
        update(uiViewController)
    }
}

/*
 struct ContentView: View {
     var body: some View {
         MyViewController()
             .asSwiftUIView()
     }
 }
 
extension UIViewController {
    func asSwiftUIView() -> some View {
        UIViewControllerWrapper(viewController: self)
    }
}

private struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(
        context: Context
    ) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        //
    }
}
*/
