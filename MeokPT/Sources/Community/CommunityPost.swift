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

// 더미 CommunityFoodList 배열
let dummyFoodList: [CommunityFoodList] = [
    CommunityFoodList(
        foodName: "닭가슴살",
        amount: 150.0,
        kcal: 165.0,
        carbohydrate: 0.0,
        protein: 31.0,
        fat: 3.6,
        dietaryFiber: nil,
        sodium: 74.0,
        sugar: 0.0
    ),
    CommunityFoodList(
        foodName: "현미밥",
        amount: 200.0,
        kcal: 220.0,
        carbohydrate: 45.0,
        protein: 4.0,
        fat: 1.5,
        dietaryFiber: 3.5,
        sodium: 5.0,
        sugar: 0.5
    ),
    CommunityFoodList(
        foodName: "샐러드",
        amount: 100.0,
        kcal: 50.0,
        carbohydrate: 10.0,
        protein: 2.0,
        fat: 0.5,
        dietaryFiber: 4.0,
        sodium: 10.0,
        sugar: 2.0
    )
]

// 더미 CommunityPost
let dummyCommunityPost = CommunityPost(
    sharedCount: 5,
    createdAt: Date(),
    title: "오늘의 건강 식단",
    content: "닭가슴살과 현미밥, 샐러드로 건강한 다이어트 식단을 만들어봤어요!",
    dietName: "다이어트 식단",
    photoURL: "https://firebasestorage.googleapis.com:443/v0/b/meokpt-3648f.firebasestorage.app/o/community_images%2F5403C6CC-5957-488A-8726-BA00FB8F093B.jpg?alt=media&token=2892f1de-4848-4657-a20e-67e2c250e118",
    userID: "user123",
    userNickname: "헬스짱",
    userProfileImageURL: "https://firebasestorage.googleapis.com:443/v0/b/meokpt-3648f.firebasestorage.app/o/profile_images%2FF6098CF1-087E-4C46-BA83-24F53E635A7F.jpg?alt=media&token=1e51a5cd-6e51-4c0d-9c26-0fe8679b850",
    foodList: dummyFoodList
)
