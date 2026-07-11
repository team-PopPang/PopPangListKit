//
//  PopPangListRepresentable.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import SwiftUI

@MainActor
struct PopPangListRepresentable: UIViewControllerRepresentable {
    let list: List
    let configuration: CollectionViewAdapterConfiguration
    
    func makeUIViewController(
        context: Context
    ) -> PopPangListViewController {
        let viewController = PopPangListViewController(
            configuration: configuration
        )
        Task { @MainActor in
            await Task.yield()
            viewController.apply(list)
        }
        return viewController
    }
    
    func updateUIViewController(
        _ viewController: PopPangListViewController,
        context: Context
    ) {
        Task { @MainActor in
            await Task.yield()
            viewController.apply(list)
        }
    }
}
