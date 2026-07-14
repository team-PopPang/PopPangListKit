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
    let prefetchingPlugins: [CollectionViewPrefetchingPlugin]

    // MARK: - SwiftUI+

    /// SwiftUI 화면이 소유하는 프로그램 스크롤 proxy입니다.
    let proxy: ListProxy?

    /// SwiftUI 화면에 연결할 scroll overlay 설정입니다.
    let scrollOverlayConfiguration: ScrollOverlayConfiguration?
    
    func makeUIViewController(
        context: Context
    ) -> PopPangListViewController {
        let viewController = PopPangListViewController(
            configuration: configuration,
            prefetchingPlugins: prefetchingPlugins
        )
        context.coordinator.schedule(
            list: list,
            viewController: viewController,
            proxy: proxy,
            scrollOverlayConfiguration: scrollOverlayConfiguration
        )
        return viewController
    }
    
    func updateUIViewController(
        _ viewController: PopPangListViewController,
        context: Context
    ) {
        context.coordinator.schedule(
            list: list,
            viewController: viewController,
            proxy: proxy,
            scrollOverlayConfiguration: scrollOverlayConfiguration
        )
    }

}

// MARK: - Coordinator
extension PopPangListRepresentable {
    static func dismantleUIViewController(
        _ viewController: PopPangListViewController,
        coordinator: Coordinator
    ) {
        coordinator.dismantle(viewController)
    }

    @MainActor
    final class Coordinator {
        private var pendingUpdate: Task<Void, Never>?

        // MARK: - SwiftUI+

        /// 현재 UIViewController와 연결된 proxy입니다.
        private weak var attachedProxy: ListProxy?

        func schedule(
            list: List,
            viewController: PopPangListViewController,
            proxy: ListProxy?,
            scrollOverlayConfiguration: ScrollOverlayConfiguration?
        ) {
            updateProxy(proxy, for: viewController)
            viewController.configureScrollOverlay(scrollOverlayConfiguration)

            // 새로운 상태가 들어올 때 다음 코드로 이전 대기 작업을 취소
            pendingUpdate?.cancel()
            pendingUpdate = Task { @MainActor [weak viewController] in
                await Task.yield()
                guard !Task.isCancelled, let viewController else {
                    return
                }
                viewController.apply(list)
            }
        }

        func dismantle(_ viewController: PopPangListViewController) {
            pendingUpdate?.cancel()
            pendingUpdate = nil
            attachedProxy?.detach(viewController)
            attachedProxy = nil
            viewController.configureScrollOverlay(nil)
        }

        private func updateProxy(
            _ proxy: ListProxy?,
            for viewController: PopPangListViewController
        ) {
            guard attachedProxy !== proxy else {
                return
            }

            attachedProxy?.detach(viewController)
            proxy?.attach(viewController)
            attachedProxy = proxy
        }

        deinit {
            pendingUpdate?.cancel()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
