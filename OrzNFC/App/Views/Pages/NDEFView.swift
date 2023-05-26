//
//  NDEFView.swift
//  OrzNFC
//
//  Created by joker on 2023/5/26.
//

import SwiftUI
import CoreNFC

enum ActionType: String, CaseIterable {
    case read = "Read"
    case write = "Write"
}

extension NFCTypeNameFormat: CaseIterable, CustomStringConvertible {

    public static var allCases: [NFCTypeNameFormat] {
        return [
            .empty,
            .nfcWellKnown,
            .media,
            .absoluteURI,
            .nfcExternal,
            .unknown,
            .unchanged
        ]
    }

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

struct NDEFView: View {

    @EnvironmentObject var appModel: AppModel

    @Binding var actionType: ActionType

    @State var records = [NFCNDEFPayload]()

    @State var recordFormat: NFCTypeNameFormat = .nfcWellKnown

    var body: some View {
        Form {
            Picker("Action Type", selection: $actionType) {
                ForEach(ActionType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.inline)
            .listRowSeparator(.hidden)

            Section("Payload") {
                if actionType == .read, let ndefMessage = appModel.ndefMessage {
                    ForEach(ndefMessage.records, id: \.payload) { PayloadView(payload: $0) }
                } else if actionType == .write {
                    Picker("Record Type", selection: $recordFormat) {
                        ForEach(NFCTypeNameFormat.allCases, id: \.self) { type in
                            Text(type.description)
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

struct NDEFView_Previews: PreviewProvider {

    static var previews: some View {

        NDEFView(actionType: .constant(.write), records: [.wellKnownTypeURIPayload(string: "https://www.baidu.com")!])
            .environmentObject(AppModel())

        NDEFView(actionType: .constant(.read))
            .environmentObject(AppModel())
    }
}
