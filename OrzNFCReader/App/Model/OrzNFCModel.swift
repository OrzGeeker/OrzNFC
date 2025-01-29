import Combine
@preconcurrency import CryptoTokenKit

actor OrzNFCModel {
    
    /// 事件取消
    private var cancelables = Set<AnyCancellable>()
    
    /// 读卡器插槽
    private var cardSlots = [String: TKSmartCardSlot]()
    
    /// 智能卡管理器
    private let _manager: TKSmartCardSlotManager? = .default
    var manager: TKSmartCardSlotManager {
        get throws {
            guard let manager = _manager
            else {
                throw OrzNFCError.invalidSmartCardManager
            }
            return manager
        }
    }
    
    /// 启动智能卡监听
    func run() async throws {
        let slotsAsyncPublisher = try manager.publisher(for: \.slotNames).values
        for await slotNames in slotsAsyncPublisher {
            for slotName in slotNames {
                guard let slot = try await manager.getSlot(withName: slotName)
                else { continue }
                // 存储读卡器实例
                cardSlots[slotName] = slot
                slot.publisher(for: \.state)
                    .filter { $0 != .probing }
                    .removeDuplicates()
                    .sink { self.processState($0, of: slot) }
                    .store(in: &cancelables)
            }
        }
    }
}
