//
//  Double++.swift
//  IdleStudy
//
//  Created by 大大 on 2025/3/19.
//

import Foundation

// MARK: - 2. Double 扩展：截断到指定小数位

extension Double {
  func truncated(to decimalPlaces: Int) -> Double {
    let multiplier = pow(10, Double(decimalPlaces))
    return floor(self * multiplier) / multiplier
  }
}
