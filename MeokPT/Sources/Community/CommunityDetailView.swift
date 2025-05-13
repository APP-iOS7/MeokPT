//
//  CommunityDetailView.swift
//  MeokPT
//
//  Created by 변영찬 on 5/12/25.
//

import SwiftUI

struct CommunityDetailView: View {
    var postTitle: String
    var postBody: String
    var imageColor: Color

    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 16) {
                // 👤 프로필
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 55, height: 55)
                    VStack(alignment: .leading) {
                        Text("닉네임")
                            .font(.subheadline)
                            .bold()
                        Text("4월 30일")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // 📷 이미지
                imageColor
                    .frame(height: 210)
                    .cornerRadius(20)

                // 📝 본문
                Text(postBody)
                    .font(.body)

                // 🍱 식단 카드
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 162)
                    .cornerRadius(20)

                // ➕ 버튼
                Button(action: {}) {
                    Text("식단 리스트에 추가")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#090909"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FAAE2B"))
                        .cornerRadius(40)
                }
            }
            .padding()
        }
        .navigationTitle(postTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackgroundColor"))
    }
}




