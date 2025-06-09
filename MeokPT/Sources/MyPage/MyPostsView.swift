//
//  MyPostsView.swift
//  MeokPT
//
//  Created by vKv on 5/9/25.
//

import SwiftUI
import ComposableArchitecture

struct MyPostsView: View {
    @Bindable var store: StoreOf<MyPostsFeature>
    
    var body: some View {
        VStack {
            if store.isLoading {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let error = store.error {
                VStack {
                    Text("게시글을 불러올 수 없습니다")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("다시 시도") {
                        store.send(.fetchCommunityPosts)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if store.postItems.isEmpty {
                Text("작성한 글이 없습니다.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: store.columns, spacing: 8) {
                        ForEach(store.filteredPosts, id: \.id) { post in
                            NavigationLink {
                                CommunityDetailView(
                                    store: Store(
                                        initialState: CommunityDetailFeature.State(
                                            navigationSource: .myPosts,
                                            communityPost: post
                                        )
                                    ) {
                                        CommunityDetailFeature()
                                    }
                                )
                            } label: {
                                CommunityPostCard(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("내가 쓴 글")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("AppBackgroundColor"))
    }
}
