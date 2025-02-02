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
        
        self.nfc
            .alertMessageSubject
            .receive(on: DispatchQueue.main)
            .sink { message in
                self.alertMessage = message
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
    
    func start(
        on tabPage: TabPageID,
        action: ActionType,
        tagPollingOption: NFCTagReaderSession.PollingOption
    ) {
        nfc.action = action
        nfc.ndefMessageToBeWrite = NFCNDEFMessage(records: [.text, .webSiteURL])
        switch tabPage {
        case .ndef:
            nfc.ndefScan()
        case .tag:
            nfc.tagScan(pollingOption: tagPollingOption)
        }
    }
}
