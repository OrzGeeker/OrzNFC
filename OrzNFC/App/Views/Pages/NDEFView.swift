import SwiftUI
import CoreNFC



struct NDEFView: View {
    
    @Environment(AppModel.self) var appModel
    
    @Binding var actionType: ActionType
    
    @State var records = [NFCNDEFPayload]()
    
    @State var recordFormat: NFCTypeNameFormat = .nfcWellKnown
    
    var body: some View {
        Form {
            ActionPicker(actionType: $actionType)
            
            Section("Payload") {
                
                if actionType == .read, let ndefMessage = appModel.ndefMessage {
                    List(ndefMessage.records, id: \.payload) { payload in
                        PayloadView(payload: payload)
                    }
                } else if actionType == .write {
                    HStack {
                        RecordTypePicker(recordFormat: $recordFormat)
                        Spacer(minLength: 20)
                        Button {
                            switch recordFormat {
                            case .nfcWellKnown:
                                records.append(.text)
                            case .absoluteURI:
                                records.append(.webSiteURL)
                            default:
                                self.appModel.alertMessage = "not supported"
                                break
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    List($records, id: \.payload, editActions: .all) { $payload in
                        PayloadView(payload: payload)
                    }
                }
            }
        }
    }
}

#Preview("Write URI") {
    NDEFView(
        actionType: .constant(.write),
        records: [
            .webSiteURL,
            .text
        ]
    ).environment(AppModel())
}

#Preview("Read") {
    NDEFView(actionType: .constant(.read))
        .environment(AppModel())
}
