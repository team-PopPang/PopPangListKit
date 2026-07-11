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
        context.coordinator.schedule(
            list: list,
            viewController: viewController
        )
        return viewController
    }
    
    func updateUIViewController(
        _ viewController: PopPangListViewController,
        context: Context
    ) {
        context.coordinator.schedule(
            list: list,
            viewController: viewController
        )
    }
}

// MARK: - Coordinator
extension PopPangListRepresentable {
    @MainActor
    final class Coordinator {
        private var pendingUpdate: Task<Void, Never>?

        func schedule(
            list: List,
            viewController: PopPangListViewController
        ) {
            // 새로운 상태가 들어올 때 다음 코드로 이전 대기 작업을 취소
            pendingUpdate?.cancel()
            pendingUpdate = Task { @MainActor in
                await Task.yield()
                guard !Task.isCancelled else {
                    return
                }
                viewController.apply(list)
            }
        }

        deinit {
            pendingUpdate?.cancel()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
