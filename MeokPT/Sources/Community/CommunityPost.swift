//
//  CommunityPost.swift
//  MeokPT
//
//  Created by 김동영 on 5/21/25.
//

import SwiftUI

struct CommunityPost: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let imageColor: Color
}

let dummyPosts: [CommunityPost] = [
    .init(title: "오늘의 식단", body: "오늘은 샐러드와 닭가슴살을 먹었습니다.", imageColor: .gray.opacity(0.3)),
    .init(title: "오후 식단", body: "오후엔 단백질 쉐이크로 간단히!", imageColor: .gray.opacity(0.3)),
    .init(title: "오전의 식단", body: "오전엔 바나나 한 개와 계란 두 개!", imageColor: .gray.opacity(0.3)),
    .init(title: "닭가슴살 샐러드", body: "단백질 폭발! 닭가슴살 + 채소 조합", imageColor: .gray.opacity(0.3)),
    .init(title: "햄버거", body: "가끔은 치팅데이도 필요하죠!", imageColor: .gray.opacity(0.3)),
    .init(title: "샐러드 식단", body: "오늘은 채소 중심의 가벼운 식단입니다.", imageColor: .gray.opacity(0.3))
]
