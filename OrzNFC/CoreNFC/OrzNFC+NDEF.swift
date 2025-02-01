import CoreNFC

extension OrzNFC: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        "ndef reader session become active".printDebugInfo()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        session.invalidate(errorMessage: error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        _ = messages.map { print($0) }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {

        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = AlertMessage.tagMoreThanOneFound
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        guard let tag = tags.first, let action = action
        else {
            session.invalidate()
            return
        }

        session.connect(to: tag, completionHandler: { (error: Error?) in

            if nil != error {
                session.alertMessage = AlertMessage.tagUnableConnect
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in

                guard error == nil
                else {
                    session.invalidate(errorMessage: AlertMessage.ndefQueryFailed)
                    return
                }

                self.process(tag: tag, of: session, status: ndefStatus, capacity: capacity, action: action)
            })
        })
        
    }
}

extension OrzNFC {

    func process(tag: NFCNDEFTag, of session: NFCNDEFReaderSession, status: NFCNDEFStatus, capacity: Int, action: ActionType) {
        var readable: Bool = false
        var writeable: Bool = false

        switch status {
        case .notSupported:
            session.invalidate(errorMessage: AlertMessage.ndefNotCompliant)
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
            guard readable else {
                session.invalidate(errorMessage: AlertMessage.ndefReadUnable)
                return
            }
            readNDEF(tag: tag, session: session)
        case .write:
            guard writeable else {
                session.invalidate(errorMessage: AlertMessage.ndefWriteUnable)
                return
            }
            writeNDEF(tag: tag, session: session, capacity: capacity)
        }
    }

    func readNDEF(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { (message: NFCNDEFMessage?, error: Error?) in
            guard error == nil, let message = message else {
                session.invalidate(errorMessage: AlertMessage.ndefReadFailed)
                return
            }
            self.ndefMessageSubject.send(message)

            session.alertMessage = AlertMessage.ndefReadSuccessed
            session.invalidate()
        }
    }

    func writeNDEF(tag: NFCNDEFTag, session: NFCNDEFReaderSession, capacity: Int) {
        if let message = ndefMessageToBeWrite {
            tag.writeNDEF(message, completionHandler: { (error: Error?) in
                guard error == nil else {
                    session.invalidate(errorMessage: "\(error!)")
                    return
                }
                session.alertMessage = AlertMessage.ndefWriteSuccessed
                session.invalidate()
            })
        }
    }
}
