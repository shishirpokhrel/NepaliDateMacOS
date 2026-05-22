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
        // 2026-01-24 => 11 Magh 2082
        let dateComponents = DateComponents(year: 2026, month: 1, day: 24)
        let date = Calendar.current.date(from: dateComponents)!
        
        let nepaliDate = NepaliDateConverter.toNepaliDate(from: date)
        print("Converted Date: \(nepaliDate.formatted)")
        
        // 11 Magh 2082
        #expect(nepaliDate.year == 2082)
        #expect(nepaliDate.month == 10)
        #expect(nepaliDate.day == 11)
    }

    @Test func testRandomDates() async throws {
        // Test random dates from 2000 to 2030 AD
        let startDate = NepaliDateConverter.gregorian.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let endDate = NepaliDateConverter.gregorian.date(from: DateComponents(year: 2030, month: 12, day: 31))!
        let timeInterval = endDate.timeIntervalSince(startDate)
        
        for _ in 0..<10 { // Test 10 random dates
            let randomInterval = TimeInterval.random(in: 0...timeInterval)
            let randomDate = startDate.addingTimeInterval(randomInterval)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            print("Attempting to convert AD: \(formatter.string(from: randomDate))")
            let bsDate = NepaliDateConverter.toNepaliDate(from: randomDate)
            print("Success -> BS: \(bsDate.formatted)")
            
            // Basic sanity check: Year should be roughly +56/57
            let adYear = Calendar.current.component(.year, from: randomDate)
            let diff = bsDate.year - adYear
            #expect(diff == 56 || diff == 57)
        }
        
        // Specific checks for known boundary dates if possible
        // 1 Jan 2000 -> 17 Poush 2056
        let y2k = NepaliDateConverter.gregorian.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        let bsY2k = NepaliDateConverter.toNepaliDate(from: y2k)
        #expect(bsY2k.year == 2056)
        #expect(bsY2k.month == 9) // Poush
        #expect(bsY2k.day == 17)
    }
}
