import Foundation
import CoreNFC
import Combine

@Observable
class AppModel: ObservableObject {
    
    // MARK: Common
    var showAlert: Bool
    
    var alertMessage: String {
        didSet {
            showAlert = true
        }
    }
    
    init(
        showAlert: Bool = false,
        alertMessage: String = "",
        ndefMessage: NFCNDEFMessage? = nil
    ) {
        self.showAlert = showAlert
        self.alertMessage = alertMessage
        self.ndefMessage = ndefMessage
        
        self.nfc
            .ndefMessageSubject
            .receive(on: DispatchQueue.main)
            .sink { ndefMessage in
                self.ndefMessage = ndefMessage
            }
            .store(in: &cancellables)
    }
    
    // MARK: Public
    var ndefMessage: NFCNDEFMessage?
    var canRead: Bool { nfc.canRead }
    
    // MARK: Private
    private var cancellables = Set<AnyCancellable>()
    private let nfc = OrzNFC()
}

extension AppModel {
    
    func startAction(
        on tabPage: TabPageID,
        actionType: ActionType
    ) {
        
        nfc.action = actionType
        
        nfc.ndefMessageToBeWrite = NFCNDEFMessage(records: [
            .text,
            .webSiteURL
        ])
        
        switch tabPage {
        case .ndef:
            nfc.ndefScan()
        case .tag:
            nfc.tagScan()
        }
    }
}
