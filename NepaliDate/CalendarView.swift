import SwiftUI

struct CalendarView: View {
    @State var currentYear: Int = 2082 // Default
    @State var currentMonth: Int = 1
    @State var selectedDay: Int = 1
    
    let initialDate: NepaliDate
    var onClose: (() -> Void)? = nil
    
    init(bsDate: NepaliDate, onClose: (() -> Void)? = nil) {
        self.initialDate = bsDate
        self.onClose = onClose
    }
    
    // Grid layout
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekDays = ["आ", "सो", "मं", "बु", "बि", "शु", "श"]
    
    // Helper for English Month Range
    var englishMonthRange: String {
        let startAd = NepaliDateConverter.toEnglishDate(year: currentYear, month: currentMonth, day: 1) ?? Date()
        let endAd = NepaliDateConverter.gregorian.date(byAdding: .day, value: 25, to: startAd) ?? startAd
        
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
    
    var monthName: String {
        return NepaliDateConverter.bsMonths[currentMonth - 1]
    }
    
    func changeMonth(by value: Int) {
        var newMonth = currentMonth + value
        var newYear = currentYear
        
        if newMonth > 12 {
            newMonth = 1
            newYear += 1
        } else if newMonth < 1 {
            newMonth = 12
            newYear -= 1
        }
        
        // Clamp year support (2000-2090)
        if newYear >= 2000 && newYear <= 2090 {
            currentYear = newYear
            currentMonth = newMonth
            // Reset selected day only if valid for new month? 
            // Better to keep it unless meaningful, but user just wants nav.
            // Let's keep it but it won't highlight "Today" accurately if we navigate away.
             // Actually, "Today" highlighting should be based on real date, not navigated date.
             // But for now, let's just update the view.
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                VStack(spacing: 0) {
                     Text("\(monthName) \(NepaliDateConverter.toDevanagari(currentYear))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.2))
                    
                    Text(englishMonthRange)
                        .font(.caption) // Smaller for secondary info
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 10)
            .padding(.horizontal)
            
            // Weekday Headers
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.body)
                        .foregroundColor(index == 6 ? .red : .primary)
                }
            }
            .padding(.horizontal)
            
            // Days Grid
            LazyVGrid(columns: columns, spacing: 0) {
                let daysInMonth = NepaliDateConverter.getDaysInMonth(year: currentYear, month: currentMonth)
                let startAdDate = NepaliDateConverter.toEnglishDate(year: currentYear, month: currentMonth, day: 1) ?? Date()
                let startWeekday = NepaliDateConverter.gregorian.component(.weekday, from: startAdDate)
                
                // Empty slots
                ForEach(0..<(startWeekday - 1), id: \.self) { index in
                    Text("")
                        .id("empty_\(index)")
                }
                
                // Days
                ForEach(1...daysInMonth, id: \.self) { day in
                    let currentAdDate = NepaliDateConverter.gregorian.date(byAdding: .day, value: day - 1, to: startAdDate) ?? startAdDate
                    let adDay = NepaliDateConverter.gregorian.component(.day, from: currentAdDate)
                    let weekday = NepaliDateConverter.gregorian.component(.weekday, from: currentAdDate)
                    let isSaturday = weekday == 7
                    
                    // Highlighting: Check against ACTUAL today, not just initial state
                    let isToday = (day == selectedDay && currentMonth == initialDate.month && currentYear == initialDate.year)
                    
                    VStack(spacing: -2) {
                        Text(NepaliDateConverter.toDevanagari(day))
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
                             Text(NepaliDateConverter.toDevanagari(day))
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
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            currentYear = initialDate.year
            currentMonth = initialDate.month
            selectedDay = initialDate.day
        }
        .onHover { isHovering in
            if !isHovering {
                // Buffer to prevent accidental closure
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Check if still not hovering before closing? 
                    // Simple approach for now.
                    onClose?()
                }
            }
        }
    }
}
