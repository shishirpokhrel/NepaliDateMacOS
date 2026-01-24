import Testing
import Foundation
@testable import NepaliDate

struct NepaliDateTests {

    @Test func checkEpoch() async throws {
        // Epoch: 13 April 1943 => 1 Baisakh 2000
        let dateComponents = DateComponents(year: 1943, month: 4, day: 13)
        let date = Calendar.current.date(from: dateComponents)!
        
        let nepaliDate = NepaliDateConverter.toNepaliDate(from: date)
        #expect(nepaliDate.formatted == "1 Baisakh 2000")
    }

    @Test func checkToday() async throws {
        // Today roughly: 2026-01-24 => 11 Magh 2082
        // Let's verify.
        let dateComponents = DateComponents(year: 2026, month: 1, day: 24)
        let date = Calendar.current.date(from: dateComponents)!
        
        let nepaliDate = NepaliDateConverter.toNepaliDate(from: date)
        print("Converted Date: \(nepaliDate.formatted)")
        #expect(nepaliDate.formatted == "11 Magh 2082")
    }
}
