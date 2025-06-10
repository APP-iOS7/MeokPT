//
//  AnalyzeHistory.swift
//  MeokPT
//
//  Created by 김동영 on 6/10/25.
//

import SwiftData
import Foundation

@Model
final class AnalyzeHistory: Identifiable, Equatable {
    var id: UUID
    var timestamp: Date
    var encodedData: String
    var cleanedResponse: String
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        encodedData: String,
        cleanedResponse: String,
    ) {
        self.id = id
        self.timestamp = timestamp
        self.encodedData = encodedData
        self.cleanedResponse = cleanedResponse
    }
}
