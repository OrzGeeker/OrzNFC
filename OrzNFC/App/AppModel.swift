//
//  AppModel.swift
//  OrzNFC
//
//  Created by joker on 2023/5/22.
//

import Foundation
import CoreNFC
import Combine

class AppModel: ObservableObject {
    
    @Published var showAlert: Bool

    var alertMessage: String {
        didSet {
            showAlert = true
        }
    }

    @Published var ndefMessage: NFCNDEFMessage?

    init(
        showAlert: Bool = false,
        alertMessage: String = "",
        ndefMessage: NFCNDEFMessage? = nil
    ) {
        self.showAlert = showAlert
        self.alertMessage = alertMessage
        self.ndefMessage = ndefMessage

        let cancellable = Self.nfc.ndefMessageSubject.receive(on: DispatchQueue.main).sink { ndefMessage in
            self.ndefMessage = ndefMessage
        }
        cancellables.append(cancellable)
    }

    private var cancellables = [AnyCancellable]()
}

extension AppModel {

    static private let nfc = OrzNFC()

    static func startAction(on tabPage: TabPageID, actionType: ActionType) {

        nfc.action = actionType
        
        switch tabPage {
        case .ndef:
            nfc.ndefScan()
        case .tag:
            nfc.tagScan()
        }
    }

    static func canRead() -> Bool { nfc.canRead }
}
