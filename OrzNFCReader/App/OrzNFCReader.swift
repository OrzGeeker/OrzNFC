import Foundation
@main
struct OrzNFCReader {
    static private let model = OrzNFCModel()
    static func main() async throws {
        do {
            try await model.run()
        } catch let error {
            error.localizedDescription.log
        }
    }
}
