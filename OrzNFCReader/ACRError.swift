//
//  ACRError.swift
//  OrzNFCReader
//
//  Created by joker on 2022/7/12.
//  Copyright © 2022 joker. All rights reserved.
//

import Foundation

/// 错误代码定义
enum ACRError: UInt8, Error {
    /// 没有错误
    case noError = 0x00
    /// 超时，目标无应答
    case timeout = 0x01
    /// 非接触 UART 检测到 CRC 错误
    case uartCRCError = 0x02
    /// 非接触 UART 检测到奇偶校验错误
    case uartParityCheckError = 0x03
    /// 在 Mifare 防冲突/选择操作中，检测到错误的位计数
    case mifareBitCountError = 0x04
    /// Mifare 卡操作过程中出现帧错误
    case mifareFrameError = 0x05
    /// 以 106 kbps 速率进行逐位补防冲突的过程中检测到异常的位冲突
    case bitConflict = 0x06
    /// 通信缓冲区的大小不足
    case bufferShortage = 0x07
    /// 非接触 UART 检测到 RF 缓冲区溢出(寄存器 CL_ERROR 的 BufferOvfl 位)
    case uartRFOverflow = 0x08
    /// 在主动通信模式下，对应方没有及时开启 RF 磁场(定义见 NFCIP-1 标准)
    case noTurnOnRF = 0x0A
    /// RF 协议错误(cf. 参考[4], CL_ERROR 寄存器的说明)
    case RFProtocolError = 0x0B
    /// 温度错误:内部温度传感器检测到过热，因此自动关闭了天线的驱动
    case temperatureError = 0x0D
    /// 内部缓冲区溢出
    case innerBufferOverflow = 0x0E
    /// 参数无效(范围，格式等)
    case invlidParameter = 0x10
    /// DEP 协议:在目标模式下配置的芯片不支持从发起者收到的命令(
    /// 收到的命令不是下列之一:ATR_REQ, WUP_REQ, PSL_REQ, DEP_REQ, DSL_REQ, RLS_REQ, ref. [1]).
    case unsupportSenderCommand = 0x12
    /// DEP 协议 / Mifare / ISO/IEC 14443-4:数据格式不符合规范。根据采用的 RF协议，可能是:
    /// - RF 接收帧的长度错误
    /// - PCB 或 PFB 值不正确
    /// - 无效的或意外的 RF 接收帧
    /// - NAD 或 DID 不一致。
    case dataFormatInvalid = 0x13
    /// Mifare:认证错误
    case mifareAuthError = 0x14
    /// ISO/IEC 14443-3:UID 检查字节错误
    case uidCheckByteError = 0x23
    /// DEP 协议:无效的设备状态，系统所处的状态不允许执行该操作
    case invalidDeviceStatus = 0x25
    /// 在此配置下不允许执行操作(主机控制器接口)
    case unallowOperation = 0x26
    /// 当前的芯片状态导致命令不能被接收(发起方 vs.目标，未知的目标号，目标状 态不佳，等等)
    case commandCannotBeReceive = 0x27
    /// 配置为目标的芯片是由其发起方发布的。
    case targetChipPublishedBySender = 0x29
    /// 仅限 ISO/IEC 14443-3B:卡片的 ID 号不匹配，意味着预期的卡片已经被调换。
    case cardIDMismatch = 0x2A
    /// 仅限 ISO/IEC 14443-3B:先前激活的卡片消失了。
    case activatedCardDisappear = 0x2B
    /// NFCID3 发起方和 NFCID3 目标方在 DEP 212/424 kbps 被动模式下不匹配
    case dismatchUnderPassiveMode = 0x2C
    /// 检测到过流事件
    case overCurrent = 0x2D
    /// DEP 结构中缺少 NAD
    case lackNAD = 0x2E
}
