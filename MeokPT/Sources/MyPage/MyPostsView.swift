//
//  MyPostsView.swift
//  MeokPT
//
//  Created by vKv on 5/9/25.
//

import SwiftUI

struct MyPostsView: View {
    let dummyPosts: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("내가 쓴 글")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.leading)
                Spacer()
                Button(action: {
                    print("글쓰기 버튼")
                }) {
                    Text("글쓰기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("AppTintColor"))
                }
                .padding(.trailing)
            }
            .padding(.top, 32)
            .padding(.bottom, 16)
            
            if dummyPosts.isEmpty {
                Spacer()
                Text("작성한 글이 없습니다.")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                List(dummyPosts, id: \.self) { post in
                    Text(post)
                        .padding(.vertical, 8)
                }
                .listStyle(.plain)
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        MyPostsView()
    }
}
