import Foundation

class CoinsManager: ObservableObject {
    static let shared = CoinsManager()

    private let coinsKey = "userCoins"
    private let userDefaults = UserDefaults.standard

    @Published var coins: Int = 0

    private init() {
        coins = userDefaults.integer(forKey: coinsKey)
    }

    func getCoins() -> Int {
        return coins
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        userDefaults.set(coins, forKey: coinsKey)
        print("添加了\(amount)个金币")
    }

    func subtractCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins = max(0, coins - amount)
        userDefaults.set(coins, forKey: coinsKey)
    }

    func resetCoins() {
        coins = 0
        userDefaults.set(0, forKey: coinsKey)
    }

    func formattedCoins() -> String {
        let amount = Double(getCoins())
        return formatNumber(amount)
    }

    private func formatNumber(_ num: Double) -> String {
        let units = ["", "K", "M", "G", "T", "P", "E", "Z", "Y"]
        var value = num
        var index = 0

        while value >= 1000 && index < units.count - 1 {
            value /= 1000
            index += 1
        }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal

        let formattedValue = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formattedValue)\(units[index])"
    }

    func fullFormattedCoins() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: getCoins())) ?? "\(getCoins())"
    }
}
