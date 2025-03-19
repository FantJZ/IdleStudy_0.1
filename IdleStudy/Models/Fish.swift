//
//  Fish.swift
//  IdleStudy
//
//  Created by JZ on 2025/3/19.
//

struct Fish: Identifiable, Codable {
    let id = UUID()
    let image: String
    let name: String
    let quality: String
    let weight: Double
    let price: Int
    let rarity: String
}
