import CoreNFC
import Combine

class OrzNFC: NSObject {
    
    /// 设置是否支持读取NFC标签信息
    var canRead: Bool { NFCReaderSession.readingAvailable }
    
    /// reader session for NDEF Tags
    private var ndefReaderSession: NFCNDEFReaderSession?
    
    /// reader session for ISO7816、ISO15693、FeliCa、MIFARE Tags
    private var tagReaderSession: NFCTagReaderSession?
    
    /// reader session for Value Added Service(VAS) Tags
    private var vasReaderSession: NFCVASReaderSession?
    
    /// Reader Action: Read or Write Data
    var action: ActionType?
    
    /// ndef message event handlers
    let ndefMessageSubject = PassthroughSubject<NFCNDEFMessage, Never>()
    
    /// ndef message to be write into tags
    var ndefMessageToBeWrite: NFCNDEFMessage?
    
    /// alert message subject
    let alertMessageSubject = PassthroughSubject<String, Never>()
}

extension OrzNFC {
    
    func ndefScan() {
        guard canRead
        else {
            alertMessageSubject.send(AlertMessage.deviceNotSupport)
            return
        }
        ndefReaderSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        guard let ndefReaderSession
        else {
            return
        }
        ndefReaderSession.alertMessage = AlertMessage.ndefAlert
        ndefReaderSession.begin()
    }
    
    func tagScan() {
        guard canRead
        else {
            alertMessageSubject.send(OrzNFC.AlertMessage.deviceNotSupport)
            return
        }
        tagReaderSession = NFCTagReaderSession(
            pollingOption: [
                .iso14443,
                .iso18092,
                .iso15693,
                .pace
            ],
            delegate: self,
            queue: nil
        )
        guard let tagReaderSession
        else {
            return
        }
        tagReaderSession.alertMessage = AlertMessage.tagAlert
        tagReaderSession.begin()
    }
}
