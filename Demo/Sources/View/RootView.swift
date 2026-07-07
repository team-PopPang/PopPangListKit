import PopPangListKit
import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Collection") {
                    NavigationLink("상세 화면") {
                        DetailView()
                    }
                }
            }
            .navigationTitle("Demo")
        }
    }
}

