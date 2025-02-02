import CoreNFC
import SwiftUI

extension NFCTagReaderSession.PollingOption: @retroactive CaseIterable {
    static let iso14443_15693_18092: NFCTagReaderSession.PollingOption = .init([
        .iso14443,
        .iso15693,
        .iso18092,
    ])
    public static var allCases: [NFCTagReaderSession.PollingOption] = [
        .iso14443_15693_18092,
        .pace,
    ]
}

extension NFCTagReaderSession.PollingOption: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .iso14443_15693_18092:
            return "ISO_14443_15693_18092"
        case .pace:
            return "pace"
        default:
            return "undefined"
        }
    }
}

extension NFCTagReaderSession.PollingOption: @retroactive Identifiable {
    public var id: String { self.description }
}

extension NFCTagReaderSession.PollingOption: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

struct TagPollingPicker: View {
    @Binding var selectedPollingOption: NFCTagReaderSession.PollingOption
    var body: some View {
        Picker("Tag Poilling Option", selection: $selectedPollingOption) {
            ForEach(NFCTagReaderSession.PollingOption.allCases) {
                Text($0.description)
                    .tag($0)
            }
        }
        .pickerStyle(.inline)
        .listRowSeparator(.hidden)
    }
}
