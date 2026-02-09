@testable import EZNetworking
import Foundation
import Testing

@Suite("SSEConnectionState Tests")
struct SSEConnectionStateTests {

    // MAR: - SSEConnectionState

    @Test("test SSEConnectionState equality", arguments: zip(connectionStateList, connectionStateList))
    func sseConnectionStateEquality(stateA: SSEConnectionState, stateB: SSEConnectionState) {
        #expect(stateA == stateB)
    }

    @Test("test SSEConnectionState inequality with different cases", arguments: zip(connectionStateList, connectionStateList.reversed()))
    func sseConnectionStateInequalityWithDifferentCases(stateA: SSEConnectionState, stateB: SSEConnectionState) {
        #expect(stateA != stateB)
    }

    @Test("test SSEConnectionState disconnected cases inequality with different disconnect reasons")
    func sseConnectionStateDisconnectedCaseInequalityWithDifferentDisconnectReasons() {
        let stateA = SSEConnectionState.disconnected(.manuallyDisconnected)
        let stateB = SSEConnectionState.disconnected(.streamEnded)
        #expect(stateA != stateB)
    }

    // MARK: - SSEConnectionState.DisconnectReason

    @Test("test SSEConnectionState.DisconnectReason equality", arguments: zip(disconnectReasonList, disconnectReasonList))
    func sseConnectionStateDisconnectReasonEquality(reasonA: SSEConnectionState.DisconnectReason, reasonB: SSEConnectionState.DisconnectReason) {
        #expect(reasonA == reasonB) 
    }

    @Test("test SSEConnectionState.DisconnectReason inequality with different cases", arguments: zip(disconnectReasonList, disconnectReasonList.reversed()))
    func sseConnectionStateDisconnectReasonInequalityWithDifferentCases(reasonA: SSEConnectionState.DisconnectReason, reasonB: SSEConnectionState.DisconnectReason) {
        #expect(reasonA != reasonB)
    }

    @Test("test SSEConnectionState.DisconnectReason streamError inequality with different error details")
    func sseConnectionStateDisconnectReasonStreamErrorInequalityWithDifferentInputs() {
        let reasonA = SSEConnectionState.DisconnectReason.streamError(NSError(domain: "SSE", code: 100))
        let reasonB = SSEConnectionState.DisconnectReason.streamError(NSError(domain: "SSE", code: 500))
        #expect(reasonA != reasonB)
    }

    // MARK: - Test Data

    private static let connectionStateList: [SSEConnectionState] = [
        .notConnected,
        .connecting,
        .connected,
        .disconnected(.streamEnded),
        .disconnected(.manuallyDisconnected),
        .disconnected(.terminated),
        .disconnected(.streamError(NSError(domain: "SSE", code: 100))),
        .disconnected(.streamError(NSError(domain: "Server", code: 500)))
    ]  

    private static let disconnectReasonList: [SSEConnectionState.DisconnectReason] = [
        SSEConnectionState.DisconnectReason.streamEnded,
        SSEConnectionState.DisconnectReason.manuallyDisconnected,
        SSEConnectionState.DisconnectReason.terminated,
        SSEConnectionState.DisconnectReason.streamError(NSError(domain: "SSE", code: 100))
    ]
}
