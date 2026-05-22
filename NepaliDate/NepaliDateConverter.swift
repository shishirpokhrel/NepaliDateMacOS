import Foundation

struct NepaliDate {
    var year: Int
    var month: Int
    var day: Int
    var weekDay: String // Nepali short day name
    
    var monthName: String {
        return NepaliDateConverter.bsMonths[month - 1]
    }
    
    var formatted: String {
        return "\(day) \(monthName) \(weekDay) \(year)"
    }

    var statusBarFormatted: String {
        return "\(day) \(monthName) \(year)"
    }
}

class NepaliDateConverter {
    
    // Use a fixed Gregorian calendar for internal logic to avoid issues with user's system settings
    static let gregorian = Calendar(identifier: .gregorian)
    
    static let bsMonths = [
        "Baisakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Aswin",
        "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra"
    ]
    
    private static let nepaliDays = ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"]

    // Epoch calibrated to Leapfrog data: 1 Baisakh 2000 BS = 14 April 1943 AD
    private static let englishEpoch: Date = {
        var components = DateComponents()
        components.year = 1943
        components.month = 4
        components.day = 14
        return gregorian.date(from: components)!
    }()
    
    static func toNepaliDate(from date: Date) -> NepaliDate {
        let startOfEpoch = gregorian.startOfDay(for: englishEpoch)
        let startOfTarget = gregorian.startOfDay(for: date)
        let daysPassed = gregorian.dateComponents([.day], from: startOfEpoch, to: startOfTarget).day ?? 0
        
        let weekdayIndex = gregorian.component(.weekday, from: date) 
        let weekDayName = nepaliDays[weekdayIndex - 1]
        
        var currentDays = daysPassed
        var currentYear = 2000
        
        while true {
            guard let daysInMonths = lookupTable[currentYear] else {
                // If year > 2090, keep calculating roughly or return fixed
                return NepaliDate(year: currentYear, month: 1, day: 1, weekDay: weekDayName)
            }
            
            let daysInYear = daysInMonths.reduce(0, +)
            
            if currentDays < daysInYear {
                break
            }
            
            currentDays -= daysInYear
            currentYear += 1
        }
        
        guard let daysInMonths = lookupTable[currentYear] else {
             return NepaliDate(year: currentYear, month: 1, day: 1, weekDay: weekDayName)
        }
        
        var currentMonth = 0
        for daysInMonth in daysInMonths {
            if currentDays < daysInMonth {
                break
            }
            currentDays -= daysInMonth
            currentMonth += 1
        }
        
        return NepaliDate(year: currentYear, month: currentMonth + 1, day: currentDays + 1, weekDay: weekDayName)
    }
    
    static func toEnglishDate(year: Int, month: Int, day: Int) -> Date? {
        guard year >= 2000, month >= 1, month <= 12, day >= 1 else { return nil }
        
        var totalDays = 0
        
        for y in 2000..<year {
            guard let daysInMonths = lookupTable[y] else { return nil }
            totalDays += daysInMonths.reduce(0, +)
        }
        
        guard let daysInMonths = lookupTable[year] else { return nil }
        
        for m in 0..<(month - 1) {
            totalDays += daysInMonths[m]
        }
        
        if day > daysInMonths[month - 1] {
            return nil
        }
        
        totalDays += (day - 1)
        
        return gregorian.date(byAdding: .day, value: totalDays, to: englishEpoch)
    }

    // Lookup Table: BS Year -> [Days in Baisakh, ..., Days in Chaitra]
    // Calibrated from Leapfrog Technology Nepali Date Picker Source
    private static let lookupTable: [Int: [Int]] = [
        2000: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2001: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2002: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2003: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2004: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2005: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2006: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2007: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2008: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
        2009: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2010: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2011: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2012: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
        2013: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2014: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2015: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2016: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
        2017: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2018: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2019: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2020: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
        2021: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2022: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
        2023: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2024: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
        2025: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2026: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2027: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2028: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2029: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
        2030: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2031: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2032: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2033: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2034: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2035: [30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
        2036: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2037: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2038: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2039: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
        2040: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2041: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2042: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2043: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
        2044: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2045: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2046: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2047: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
        2048: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2049: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
        2050: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2051: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
        2052: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2053: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
        2054: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2055: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2056: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
        2057: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2058: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2059: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2060: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2061: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2062: [30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
        2063: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2064: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2065: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2066: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
        2067: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2068: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2069: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2070: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
        2071: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2072: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
        2073: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
        2074: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
        2075: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2076: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
        2077: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        2078: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
        2079: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
        2080: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
        2081: [31, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30],
        2082: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
        2083: [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
        2084: [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
        2085: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30],
        2086: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
        2087: [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
        2088: [30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30],
        2089: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
        2090: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30]
    ]
    
    static func getDaysInMonth(year: Int, month: Int) -> Int {
        guard let daysInMonths = lookupTable[year], month >= 1, month <= 12 else {
            return 32 // Fallback
        }
        return daysInMonths[month - 1]
    }
    
    static func toDevanagari(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ne_NP")
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
