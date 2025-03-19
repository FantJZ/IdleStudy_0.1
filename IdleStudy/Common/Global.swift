//
//  Global.swift
//  IdleStudy
//
//  Created by 大大 on 2025/3/19.
//

import Foundation

// MARK: - LOG

func printlog<T>(
  _ message: T,
  file: String = #file,
  line: Int = #line,
  method: String = #function
) {
  let date = DateSingle.shared.logDateFormatter.string(from: Date())
  let text = "[Cloud Master] [\(date)] [\((file as NSString).lastPathComponent) line: \(line), method: \(method)]: \n\(message)"
  #if DEBUG
    print("\(text)")
  #endif
}

// MARK: - DateSingle

class DateSingle {
  static let shared = DateSingle()

  lazy var logDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss SSS"
    return formatter
  }()
}
