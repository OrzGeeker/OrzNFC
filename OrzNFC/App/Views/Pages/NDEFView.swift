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

struct NDEFView: View {

    @EnvironmentObject var appModel: AppModel

    @Binding var actionType: ActionType

    var body: some View {
        Form {
            Picker("Action Type", selection: $actionType) {
                ForEach(ActionType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.inline)
            .listRowSeparator(.hidden)

            if let ndefMessage = appModel.ndefMessage {
                Section("Payload") {
                    ForEach(ndefMessage.records, id: \.payload) { payload in
                        PayloadView(payload: payload)
                    }
                }
            }
        }
    }
}

struct NDEFView_Previews: PreviewProvider {
    static var previews: some View {
        NDEFView(actionType: .constant(.read))
    }
}
