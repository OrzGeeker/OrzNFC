import SwiftUI

enum ActionType: String, CaseIterable {
    case read = "Read"
    case write = "Write"
}

extension ActionType: Identifiable {
    var id: String { self.rawValue }
}

struct ActionPicker: View {
    @Binding var actionType: ActionType
    
    var body: some View {
        Picker("Action Type", selection: $actionType) {
            ForEach(ActionType.allCases) {
                Text($0.rawValue)
                    .tag($0)
            }
        }
        .pickerStyle(.inline)
        .listRowSeparator(.hidden)
    }
}
