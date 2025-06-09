//
//  SharedPostRecord.swift
//  MeokPT
//
//  Created by 김동영 on 6/9/25.
//

import SwiftData
import Foundation

@Model
class SharedPostRecord {
    var communityPostID: String
    var sharedAt: Date
    
    init(communityPostID: String, sharedAt: Date) {
        self.communityPostID = communityPostID
        self.sharedAt = sharedAt
    }
}
