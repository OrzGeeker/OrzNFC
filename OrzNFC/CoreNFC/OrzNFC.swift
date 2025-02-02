import CoreNFC
import Combine

class OrzNFC: NSObject {
    
    /// 设置是否支持读取NFC标签信息
    var canRead: Bool { NFCReaderSession.readingAvailable }
    
    /// reader session for NDEF Tags
    var ndefReaderSession: NFCNDEFReaderSession?
    
    /// reader session for ISO7816、ISO15693、FeliCa、MIFARE Tags
    var tagReaderSession: NFCTagReaderSession?
    
    /// reader session for Value Added Service(VAS) Tags
    var vasReaderSession: NFCVASReaderSession?
    
    /// Reader Action: Read or Write Data
    var action: ActionType?
    
    /// ndef message event handlers
    let ndefMessageSubject = PassthroughSubject<NFCNDEFMessage, Never>()
    
    /// ndef message to be write into tags
    var ndefMessageToBeWrite: NFCNDEFMessage?
    
    /// alert message subject
    let alertMessageSubject = PassthroughSubject<String, Never>()
}
