import CoreNFC

extension OrzNFC: NFCNDEFReaderSessionDelegate {
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Do not add code in this function. This method isn't called
        // when you provide `readerSession(_:didDetect:)`.
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        "ndef reader session become active, and ready to read/write".printDebugInfo()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        guard
            let readerError = error as? NFCReaderError,
            readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
            readerError.code != .readerSessionInvalidationErrorUserCanceled,
            readerError.code != .readerSessionInvalidationErrorSystemIsBusy
        else {
            error.localizedDescription.printDebugInfo()
            return
        }
        // Show an alert when the invalidation reason is not because of a
        // successful read during a single-tag read session, or because the
        // user canceled a multiple-tag read session from the UI or
        // programmatically using the invalidate method call.
        alertMessageSubject.send(error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = AlertMessage.tagMoreThanOneFound
            self.ndefTagRemovalDetect(tags.first!)
            return
        }
        guard let tag = tags.first, let action = action
        else {
            session.invalidate(errorMessage: AlertMessage.tagUnableDetect)
            return
        }
        session.connect(to: tag) { (error: Error?) in
            guard error == nil
            else {
                session.invalidate(errorMessage: AlertMessage.tagUnableConnect)
                return
            }
            tag.queryNDEFStatus { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil
                else {
                    session.invalidate(errorMessage: AlertMessage.ndefQueryFailed)
                    return
                }
                self.process(tag: tag, of: session, status: ndefStatus, capacity: capacity, action: action)
            }
        }
        
    }
}

extension OrzNFC {
    
    func process(
        tag: NFCNDEFTag,
        of session: NFCNDEFReaderSession,
        status: NFCNDEFStatus,
        capacity: Int,
        action: ActionType
    ) {
        var readable: Bool = false
        var writeable: Bool = false
        
        switch status {
        case .notSupported:
            session.invalidate(errorMessage: AlertMessage.ndefNotCompliant)
            return
        case .readOnly:
            readable = true
        case .readWrite:
            readable = true
            writeable = true
        @unknown default:
            session.invalidate(errorMessage: AlertMessage.ndefUnknownStatus)
            return
        }
        
        switch action {
        case .read:
            guard readable
            else {
                session.invalidate(errorMessage: AlertMessage.ndefReadUnable)
                return
            }
            readNDEF(tag: tag, session: session)
        case .write:
            guard writeable
            else {
                session.invalidate(errorMessage: AlertMessage.ndefWriteUnable)
                return
            }
            writeNDEF(tag: tag, session: session, capacity: capacity)
        }
    }
    
    func readNDEF(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { (message: NFCNDEFMessage?, error: Error?) in
            guard error == nil, let message = message
            else {
                session.invalidate(errorMessage: AlertMessage.ndefReadFailed)
                return
            }
            self.ndefMessageSubject.send(message)
            session.alertMessage = AlertMessage.ndefReadSuccessed
            session.invalidate()
        }
    }
    
    func writeNDEF(tag: NFCNDEFTag, session: NFCNDEFReaderSession, capacity: Int) {
        guard let message = ndefMessageToBeWrite,
              message.length <= capacity
        else {
            session.alertMessage = AlertMessage.ndefTagCapacityTooSmall
            return
        }
        tag.writeNDEF(message, completionHandler: { (error: Error?) in
            guard error == nil
            else {
                session.invalidate(errorMessage: AlertMessage.ndefWriteFailed)
                return
            }
            session.alertMessage = AlertMessage.ndefWriteSuccessed
            session.invalidate()
        })
    }
}
