import PopPangListKit
import SwiftUI

struct PopPangListKitCatalogView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Module") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PopPangListKit")
                            .font(.title2.weight(.bold))

                        Text("This demo app is the starting point for validating PopPang's internal ListKit migration.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Status") {
                    LabeledContent("Module Type", value: String(describing: PopPangListKitModule.self))
                    LabeledContent("Goal", value: "SwiftUI list powered by UICollectionView delegate support")
                }
            }
            .navigationTitle("PopPangListKit")
        }
    }
}
