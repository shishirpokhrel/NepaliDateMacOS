import SwiftUI

struct CalendarView: View {
    let bsDate: NepaliDate
    
    // Grid layout
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekDays = ["आ", "सो", "मं", "बु", "बि", "शु", "श"] // Shortened as per reference
    
    // Helper to convert to Devanagari
    func toDevanagari(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ne_NP")
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    // Helper for English Month Range (e.g., "Jan/Feb '26")
    var englishMonthRange: String {
        // Start date AD
        let startAd = NepaliDateConverter.toEnglishDate(year: bsDate.year, month: bsDate.month, day: 1) ?? Date()
        // End date AD (rough approx + 30 days)
        let endAd = Calendar.current.date(byAdding: .day, value: 25, to: startAd)! // A few days into next English month usually
        
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        let startMonth = fmt.string(from: startAd)
        let endMonth = fmt.string(from: endAd)
        
        fmt.dateFormat = "yy"
        let year = fmt.string(from: startAd)
        
        if startMonth == endMonth {
            return "\(startMonth) '\(year)"
        } else {
            return "\(startMonth)/\(endMonth) '\(year)"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("\(bsDate.monthName) \(toDevanagari(bsDate.year))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.2)) // Greenish
                
                Text(englishMonthRange)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            
            // Weekday Headers
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.body)
                        .foregroundColor(index == 6 ? .red : .primary) // Saturday Red
                }
            }
            .padding(.horizontal)
            
            // Days Grid
            LazyVGrid(columns: columns, spacing: 0) { // Tighter spacing
                let daysInMonth = NepaliDateConverter.getDaysInMonth(year: bsDate.year, month: bsDate.month)
                let startAdDate = NepaliDateConverter.toEnglishDate(year: bsDate.year, month: bsDate.month, day: 1) ?? Date()
                let startWeekday = Calendar.current.component(.weekday, from: startAdDate) // 1=Sun
                
                // Empty slots
                ForEach(0..<(startWeekday - 1), id: \.self) { _ in
                    Text("")
                }
                
                // Days
                ForEach(1...daysInMonth, id: \.self) { day in
                    let currentAdDate = Calendar.current.date(byAdding: .day, value: day - 1, to: startAdDate)!
                    let adDay = Calendar.current.component(.day, from: currentAdDate)
                    let weekday = Calendar.current.component(.weekday, from: currentAdDate)
                    let isSaturday = weekday == 7
                    let isToday = day == bsDate.day // Highlighting "selected" date from input, ideally should be Today check
                    
                    VStack(spacing: -2) {
                        Text(toDevanagari(day))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(isSaturday ? .red : .primary)
                        
                        Text("\(adDay)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .scaleEffect(0.8)
                    }
                    .frame(width: 40, height: 45)
                    .background(
                        isToday ? RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.8)) : nil
                    )
                    .overlay(
                        isToday ? VStack(spacing: -2) {
                             Text(toDevanagari(day))
                                 .font(.title3)
                                 .fontWeight(.medium)
                                 .foregroundColor(.white)
                             Text("\(adDay)")
                                 .font(.caption2)
                                 .foregroundColor(.white.opacity(0.9))
                                 .scaleEffect(0.8)
                        } : nil
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
        }
        .frame(width: 320)
        .background(Color(NSColor.windowBackgroundColor)) // Match popup background
    }
}
