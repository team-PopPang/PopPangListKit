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
                
                Section("PopPangListKit") {
                    NavigationLink("example 1") {
                        ViewControllerRepresentable {
                            VerticalLayoutVC()
                        }
                    }
                    
                    NavigationLink("example 2") {
                        PopPangSwiftUIView()
                    }

                    NavigationLink("example 3 - Interactive SwiftUI cells") {
                        PopPangInteractiveSwiftUIView()
                    }

                    NavigationLink("example 4 - Home list") {
                        HomeListExample()
                    }

                    NavigationLink("example 5 - Async layout reproduction") {
                        AsyncPopupLayoutExample()
                    }

                    NavigationLink("example 6 - Section ID & Animation") {
                        SectionScopedIdentityExample()
                    }
                }
            }
            .navigationTitle("Demo")
        }
    }
}
