import SwiftUI
import CoreNFC

struct OtherTagView: View {
    @Environment(AppModel.self) var appModel
    @Binding var actionType: ActionType
    @Binding var pollingOption: NFCTagReaderSession.PollingOption
    var body: some View {
        Form {
            ActionPicker(actionType: $actionType)
            
            TagPollingPicker(selectedPollingOption: $pollingOption)
        }
    }
}

#Preview {
    OtherTagView(
        actionType: .constant(.read),
        pollingOption: .constant(.iso14443)
    ).environment(AppModel())
}
