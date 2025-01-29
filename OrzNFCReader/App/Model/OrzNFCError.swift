@preconcurrency import CryptoTokenKit

enum OrzNFCError: String, Error {
    case invalidSmartCardManager = """
    The com.apple.security.smartcard entitlement is required in order to use TKSmartCardSlotManager.
    """
}
