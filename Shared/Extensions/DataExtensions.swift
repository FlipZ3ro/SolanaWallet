import Foundation
import SwiftUI

// MARK: - Data Extensions

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }

    init?(hexString: String) {
        let hex = hexString.dropFirst(hexString.hasPrefix("0x") ? 2 : 0)
        guard hex.count % 2 == 0 else { return nil }

        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }
}

// MARK: - String Extensions

extension String {
    var isValidSolanaAddress: Bool {
        let base58Regex = "^[1-9A-HJ-NP-Za-km-z]{32,44}$"
        return range(of: base58Regex, options: .regularExpression) != nil
    }

    var truncatedAddress: String {
        guard count > 12 else { return self }
        let prefix = prefix(6)
        let suffix = suffix(4)
        return "\(prefix)...\(suffix)"
    }
}

// MARK: - Date Extensions

extension Date {
    var timeAgoDisplay: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self,
            to: now
        )

        if let years = components.year, years > 0 {
            return "\(years)y ago"
        }
        if let months = components.month, months > 0 {
            return "\(months)mo ago"
        }
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }
        if let seconds = components.second, seconds > 0 {
            return "\(seconds)s ago"
        }
        return "Just now"
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .padding(AppConstants.UI.padding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
    }
}

// MARK: - Color Extensions

extension Color {
    static let solanaGreen = Color(red: 0.0, green: 1.0, blue: 0.59)
    static let solanaPurple = Color(red: 0.45, green: 0.17, blue: 0.89)
    static let solanaBlue = Color(red: 0.0, green: 0.44, blue: 1.0)
}
