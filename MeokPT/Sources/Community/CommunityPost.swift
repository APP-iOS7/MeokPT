//
//  CommunityPost.swift
//  MeokPT
//
//  Created by 김동영 on 6/7/25.
//

import Foundation

struct CommunityPost: Identifiable, Equatable {
    let id = UUID()

    var sharedCount: Int
    
    let createdAt: Date
    let title: String
    let content: String
    let dietName: String
    let photoURL: String
    let userID: String
    let userNickname: String
    let userProfileImageURL: String
    
    let foodList: [CommunityFoodList]
}

struct CommunityFoodList: Equatable {
    var foodName: String
    var amount: Double
    var kcal: Double
    var carbohydrate: Double?
    var protein: Double?
    var fat: Double?
    var dietaryFiber: Double?
    var sodium: Double?
    var sugar: Double?
}
