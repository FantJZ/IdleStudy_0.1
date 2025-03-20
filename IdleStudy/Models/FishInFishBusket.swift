
// File: Models/FishInFishBusket.swift
import Foundation

struct FishInFishBusket: Identifiable, Codable {
    let id = UUID()
    let image: String
    let name: String
    let quality: String
    let weight: Double
    let price: Int
    let rarity: String
    
    enum CodingKeys: String, CodingKey {
        case image, name, quality, weight, price, rarity
    }
}
