import SwiftUI

struct ConverterView: View {
    @State private var conversionMode = 0 // 0: AD to BS, 1: BS to AD
    
    // AD to BS State
    @State private var adYear: Int = Calendar.current.component(.year, from: Date())
    @State private var adMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var adDay: Int = Calendar.current.component(.day, from: Date())
    @State private var convertedBsDateStr: String = ""
    
    // BS to AD State
    @State private var bsYear: Int = 2082
    @State private var bsMonth: Int = 1
    @State private var bsDay: Int = 1
    @State private var convertedAdDateStr: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Mode", selection: $conversionMode) {
                Text("AD to BS").tag(0)
                Text("BS to AD").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Divider()
            
            if conversionMode == 0 {
                // AD to BS Mode
                VStack(spacing: 20) {
                    Text("Enter English Date (AD)")
                        .font(.headline)
                    
                    HStack {
                        InputField(title: "Year", value: $adYear, width: 80)
                        InputField(title: "Month", value: $adMonth, width: 60)
                        InputField(title: "Day", value: $adDay, width: 60)
                    }
                    
                    Button("Convert") {
                        let components = DateComponents(year: adYear, month: adMonth, day: adDay)
                        if let date = Calendar.current.date(from: components) {
                            let bsDate = NepaliDateConverter.toNepaliDate(from: date)
                            convertedBsDateStr = bsDate.formatted
                        } else {
                            convertedBsDateStr = "Invalid Date"
                        }
                    }
                    .padding(.top, 5) // Add some padding instead
                    
                    ResultView(title: "Nepali Date (BS)", result: convertedBsDateStr)
                }
            } else {
                // BS to AD Mode
                VStack(spacing: 20) {
                    Text("Enter Nepali Date (BS)")
                        .font(.headline)
                    
                    HStack {
                        InputField(title: "Year", value: $bsYear, width: 80)
                        InputField(title: "Month", value: $bsMonth, width: 60)
                        InputField(title: "Day", value: $bsDay, width: 60)
                    }
                    
                    Button("Convert") {
                        if let date = NepaliDateConverter.toEnglishDate(year: bsYear, month: bsMonth, day: bsDay) {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .full
                            convertedAdDateStr = formatter.string(from: date)
                        } else {
                            convertedAdDateStr = "Invalid Date"
                        }
                    }
                    .padding(.top, 5) // Add some padding instead
                    
                    ResultView(title: "English Date (AD)", result: convertedAdDateStr)
                }
            }
            
            Spacer()
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .frame(width: 400, height: 400)
    }
}

// Helper Views
struct InputField: View {
    let title: String
    @Binding var value: Int
    let width: CGFloat
    
    // Create a static formatter to avoid recreation
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption)
            TextField(title, value: $value, formatter: Self.numberFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Explicit style for older OS
                .frame(width: width)
        }
    }
}

struct ResultView: View {
    let title: String
    let result: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(result.isEmpty ? "Tap Convert" : result)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
}
