import SwiftUI
import CoreNFC

enum ActionType: String, CaseIterable {
    case read = "Read"
    case write = "Write"
}

extension ActionType: Identifiable {
    var id: String { self.rawValue }
}

extension NFCTypeNameFormat: @retroactive CaseIterable {
    public static var allCases: [NFCTypeNameFormat] {
        return [
            .empty,
            .nfcWellKnown,
            .media,
            .absoluteURI,
            .nfcExternal,
            .unknown,
            .unchanged,
        ]
    }
}

extension NFCTypeNameFormat: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "empty"
        case .nfcWellKnown:
            return "wellKnown"
        case .media:
            return "media"
        case .absoluteURI:
            return "URI"
        case .nfcExternal:
            return "external"
        case .unknown:
            return "unknown"
        case .unchanged:
            return "unchanged"
        @unknown default:
            fatalError("Invalid Format")
        }
    }
}

extension NFCTypeNameFormat: @retroactive Identifiable {
    public var id: UInt8 { self.rawValue }
}

struct NDEFView: View {
    
    @Environment(AppModel.self) var appModel
    
    @Binding var actionType: ActionType
    
    @State var records = [NFCNDEFPayload]()
    
    @State var recordFormat: NFCTypeNameFormat = .nfcWellKnown
    
    var body: some View {
        Form {
            Picker("Action Type", selection: $actionType) {
                ForEach(ActionType.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.inline)
            .listRowSeparator(.hidden)
            
            Section("Payload") {
                if actionType == .read, let ndefMessage = appModel.ndefMessage {
                    ForEach(ndefMessage.records, id: \.payload) {
                        PayloadView(payload: $0)
                    }
                } else if actionType == .write {
                    Picker("Record Type", selection: $recordFormat) {
                        ForEach(NFCTypeNameFormat.allCases) {
                            Text($0.description)
                        }
                    }
                    ForEach(records, id: \.payload) { payload in
                        HStack {
                            PayloadView(payload: payload)
                            Spacer()
                            Button {
                                records.removeAll { item in
                                    return payload == item
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    HStack {
                        Button {
                            records.append(.init(format: recordFormat, type: Data(), identifier: Data(), payload: Data()))
                        } label: {
                            Image(systemName: "plus.circle")
                        }
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
