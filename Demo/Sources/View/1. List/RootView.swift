import PopPangListKit
import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("UICollectionViewCompositionalLayout") {
                    NavigationLink("example 1") {
                        ViewControllerRepresentable {
                            CollectionViewCompositionalLayoutVC()
                        }
                    }
                }
            }
            .navigationTitle("Demo")
        }
    }
}

