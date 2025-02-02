import CoreNFC

// MARK: Tag Reader Session
extension OrzNFC {
    
    func tagScan(pollingOption: NFCTagReaderSession.PollingOption) {
        guard canRead
        else {
            alertMessageSubject.send(OrzNFC.AlertMessage.deviceNotSupport)
            return
        }
        tagReaderSession = NFCTagReaderSession(
            pollingOption: pollingOption,
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

// MARK: NFCTagReaderSessionDelegate
extension OrzNFC: NFCTagReaderSessionDelegate {
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // If necessary, you may perform additional operations on session start.
        // At this point RF polling is enabled.
        "Tag Reader Session Become Active".printDebugInfo()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // If necessary, you may handle the error. Note session is no longer valid.
        // You must create a new session to restart RF polling.
        if let readerError = error as? NFCReaderError {
            readerError.localizedDescription.printDebugInfo()
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            session.alertMessage = AlertMessage.tagMoreThanOneFound
            self.tagRemovalDetect(tags.first!)
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
            self.process(tag: tag, of: session, action: action)
        }
    }
}

// MARK: Read/Write Process
extension OrzNFC {
    func process(
        tag: NFCTag,
        of session: NFCTagReaderSession,
        action: ActionType
    ) {
        if case let .feliCa(feliCaTag) = tag {
            alertMessageSubject.send("feliCaTag: \(feliCaTag.description)")
        } else if case let .iso15693(iso15693Tag) = tag {
            alertMessageSubject.send("iso15693Tag: \(iso15693Tag.description)")
        } else if case let .iso7816(iso7816Tag) = tag {
            alertMessageSubject.send("iso7816Tag: \(iso7816Tag.description)")
        } else if case let .miFare(mifareTag) = tag {
            var family: String
            switch mifareTag.mifareFamily {
            case .unknown:
                family = "unknown"
            case .ultralight:
                family = "ultralight"
            case .desfire:
                family = "desfire"
            case .plus:
                family = "plus"
            @unknown default:
                family = "undefined"
            }
            alertMessageSubject.send("mifareTag: \(family)")
        } else {
            alertMessageSubject.send("unknown tag")
        }
        session.invalidate()
    }
}
