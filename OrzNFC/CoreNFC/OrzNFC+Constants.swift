extension OrzNFC {
    struct AlertMessage {
        static let deviceNotSupport = "This Device doesn't support tag scanning."
        static let ndefAlert = "Hold your iPhone near a NFC NDEF tag."
        static let tagAlert = "Hold your iPhone near a NFC tag to read."
        static let tagReadOnly = "Tag is read only."
        static let tagReadWrite = "Tag is readwrite."
        static let tagUnableDetect = "Unable detect a tag"
        static let tagUnableConnect = "Unable to connect to tag."
        static let tagMoreThanOneFound = "More than 1 tag is detected. Please remove all tags and try again."
        
        // NDEF
        static let ndefNotCompliant = "Tag is not NDEF compliant."
        static let ndefQueryFailed = "Unable to query the NDEF status of tag."
        static let ndefUnknownStatus = "Unknown NDEF tag status."
        static let ndefReadUnable = "Unable to read the NDEF."
        static let ndefReadFailed = "Read NDEF message failed."
        static let ndefReadSuccessed = "Read NDEF message successful."
        static let ndefWriteUnable = "Unable to write the NDEF."
        static let ndefWriteFailed  = "Write NDEF message failed."
        static let ndefWriteSuccessed = "Write NDEF message successful."
        static let ndefReaderSessionNotReady = "NDEF Reader is not Ready"
        static let ndefTagCapacityTooSmall = "Tag capacity is too small."
    }
}

// MARK: For Test
import CoreNFC
extension NFCNDEFPayload {
    
    static let webSiteURL = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "https://www.example.com")!
    
    static let email = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "mailto:user@example.com")!
    
    static let sms = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "sms:+14085551212")!
    
    static let telephone = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "tel:+14085551212")!
    
    static let faceTime = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "facetime://user@example.com")!
    
    static let text = NFCNDEFPayload
        .wellKnownTypeTextPayload(
            string: "Hello, NFC",
            locale: .current)!
    
    static let empty = NFCNDEFPayload(
        format: .empty,
        type: Data(),
        identifier: Data(),
        payload: Data()
    )
    
    static let faceTimeAudio = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "facetime-audio://user@example.com")!
    
    static let maps = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "http://maps.apple.com/?address=Apple%20Park,Cupertino,California")!
    
    static let homeKit = NFCNDEFPayload
        .wellKnownTypeURIPayload(string: "X-HM://12345")!
}
