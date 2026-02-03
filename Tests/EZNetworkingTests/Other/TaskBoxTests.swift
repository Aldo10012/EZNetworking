@testable import EZNetworking
import Foundation
import Testing

@Suite("Test TaskBox")
final class TaskBoxTests {
    @Test("test TaskBox initial value is nil")
    func taskBox_initialValue_isNil() {
        let box = TaskBox()
        #expect(box.task == nil)
    }

    @Test("test TaskBox setter")
    func taskBox_setter() {
        let box = TaskBox()
        box.task = Task {}
        #expect(box.task != nil)
    }
}
