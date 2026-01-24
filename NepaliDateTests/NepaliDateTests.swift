import Testing
import Foundation
@testable import NepaliDate

struct NepaliDateTests {

    @Test func checkEpoch() async throws {
        // Epoch: 14 April 1943 => 1 Baisakh 2000
        let dateComponents = DateComponents(year: 1943, month: 4, day: 14)
        let date = Calendar.current.date(from: dateComponents)!
        
        let nepaliDate = NepaliDateConverter.toNepaliDate(from: date)
        // Note: New format includes weekday, but we can verify parts or strict match if we know weekday
        // April 14, 1943 was a Wednesday (Budha)
        #expect(nepaliDate.year == 2000)
        #expect(nepaliDate.month == 1)
        #expect(nepaliDate.day == 1)
    }

    @Test func checkToday() async throws {
        // 2026-01-24 => 10 Magh 2082
        let dateComponents = DateComponents(year: 2026, month: 1, day: 24)
        let date = Calendar.current.date(from: dateComponents)!
        
        let nepaliDate = NepaliDateConverter.toNepaliDate(from: date)
        print("Converted Date: \(nepaliDate.formatted)")
        
        // 10 Magh 2082
        #expect(nepaliDate.year == 2082)
        #expect(nepaliDate.month == 10)
        #expect(nepaliDate.day == 10)
    }
}
