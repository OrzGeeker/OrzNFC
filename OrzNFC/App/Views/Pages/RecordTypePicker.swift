import SwiftUI
import CoreNFC

struct RecordTypePicker: View {
    @Binding var recordFormat: NFCTypeNameFormat
    
    var body: some View {
        Picker("Record Type", selection: $recordFormat) {
            ForEach(NFCTypeNameFormat.allCases) {
                Text($0.description)
                    .tag($0)
            }
        }
    }
}

extension NFCTypeNameFormat: @retroactive CaseIterable {
    public static var allCases: [NFCTypeNameFormat] {
        return [
            .empty,
            .nfcWellKnown,
            .media,
            .absoluteURI,
            .nfcExternal,
            .unknown,
            .unchanged,
        ]
    }
}

extension NFCTypeNameFormat: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "empty"
        case .nfcWellKnown:
            return "wellKnown"
        case .media:
            return "media"
        case .absoluteURI:
            return "URI"
        case .nfcExternal:
            return "external"
        case .unknown:
            return "unknown"
        case .unchanged:
            return "unchanged"
        @unknown default:
            fatalError("Invalid Format")
        }
    }
}

extension NFCTypeNameFormat: @retroactive Identifiable {
    public var id: UInt8 { self.rawValue }
}
