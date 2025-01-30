@preconcurrency import CryptoTokenKit

enum OrzNFCError: String, Error {
    case invalidSmartCardManager = """
    The com.apple.security.smartcard entitlement is required in order to use TKSmartCardSlotManager.
    """
    case notReceiveAnswerToReset = "no ATR"
    case makeSmartCardFailed = "make smart card failed!"
}

extension OrzNFCError {
    var log: Void { return self.rawValue.log("OrzNFCError: ") }
}
