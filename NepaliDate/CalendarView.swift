import SwiftUI

struct CalendarView: View {
    let bsDate: NepaliDate
    
    // Grid layout
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekDays = ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"]
    
    // Helper to convert to Devanagari
    func toDevanagari(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ne_NP")
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Text("\(bsDate.monthName) \(toDevanagari(bsDate.year))")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 5)
            
            // Weekday Headers
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            
            // Days Grid
            LazyVGrid(columns: columns, spacing: 10) {
                // Calculate padding cells and actual days
                let daysInMonth = NepaliDateConverter.getDaysInMonth(year: bsDate.year, month: bsDate.month)
                
                // Get weekday of 1st day of month
                let startAdDate = NepaliDateConverter.toEnglishDate(year: bsDate.year, month: bsDate.month, day: 1) ?? Date()
                let startWeekday = Calendar.current.component(.weekday, from: startAdDate) // 1=Sun
                
                // Empty slots before 1st day
                ForEach(0..<(startWeekday - 1), id: \.self) { _ in
                    Text("")
                }
                
                // Days
                ForEach(1...daysInMonth, id: \.self) { day in
                    // Calculate AD day for this BS day
                    // Efficient way check: simple add days to startAdDate
                    let currentAdDate = Calendar.current.date(byAdding: .day, value: day - 1, to: startAdDate)!
                    let adDay = Calendar.current.component(.day, from: currentAdDate)
                    
                    VStack(spacing: 0) {
                        Text(toDevanagari(day))
                            .font(.title3)
                            .fontWeight(day == bsDate.day ? .bold : .regular)
                            .foregroundColor(day == bsDate.day ? .blue : .primary)
                        
                        Text("\(adDay)")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 30, height: 35)
                    .background(day == bsDate.day ? Circle().fill(Color.blue.opacity(0.1)) : nil)
                }
            }
        }
        .padding()
        .frame(width: 320)
    }
}
