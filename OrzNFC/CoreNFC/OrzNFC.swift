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

/// NDEF Reader Session
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
    
    func ndefTagRemovalDetect(_ tag: NFCNDEFTag) {
        // In the tag removal procedure, you connect to the tag and query for
        // its availability. You restart RF polling when the tag becomes
        // unavailable; otherwise, wait for certain period of time and repeat
        // availability checking.
        self.ndefReaderSession?.connect(to: tag) { (error: Error?) in
            guard error == nil && tag.isAvailable
            else {
                "Restart polling".printDebugInfo()
                self.ndefReaderSession?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(
                deadline: DispatchTime.now() + .milliseconds(500),
                execute: {
                    self.ndefTagRemovalDetect(tag)
                }
            )
        }
    }
}

/// Tag Reader Session
extension OrzNFC {
    
    func tagScan() {
        guard canRead
        else {
            alertMessageSubject.send(OrzNFC.AlertMessage.deviceNotSupport)
            return
        }
        tagReaderSession = NFCTagReaderSession(
            pollingOption: [
                .iso14443,
                .iso15693,
                .iso18092,
//                .pace,
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
    
    func tagRemovalDetect(_ tag: NFCTag) {
        // In the tag removal procedure, you connect to the tag and query for
        // its availability. You restart RF polling when the tag becomes
        // unavailable; otherwise, wait for certain period of time and repeat
        // availability checking.
        self.tagReaderSession?.connect(to: tag) { (error: Error?) in
            guard error == nil && tag.isAvailable
            else {
                "Restart polling".printDebugInfo()
                self.tagReaderSession?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(
                deadline: DispatchTime.now() + .milliseconds(500),
                execute: {
                    self.tagRemovalDetect(tag)
                }
            )
        }
    }
}

