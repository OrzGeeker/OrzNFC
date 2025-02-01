import CoreNFC

extension OrzNFC: NFCTagReaderSessionDelegate {
        
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        "Tag Reader Session Become Active".printDebugInfo()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            readerError.localizedDescription.printDebugInfo()
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        _ = tags.map { print($0) }
    }
}
