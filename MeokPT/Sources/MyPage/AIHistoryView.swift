//
//  AIHistoryView.swift
//  MeokPT
//
//  Created by 김동영 on 6/10/25.
//

import SwiftUI
import ComposableArchitecture
import MarkdownUI

struct AIHistoryView: View {
    @Bindable var store: StoreOf<AIHistoryFeature>
    
    var body: some View {
        VStack {
            if store.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("분석 기록을 불러오는 중...")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if store.historyItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray.opacity(0.6))
                    
                    Text("저장된 분석이 없습니다")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("AI 분석을 받은 후 저장하면\n이곳에서 확인할 수 있습니다")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            } else {
                List {
                    ForEach(store.historyItems, id: \.id) { item in
                        HistoryItemRow(item: item) {
                            store.send(.selectItem(item))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                store.send(.deleteItem(item.persistentModelID))
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            if let errorMessage = store.errorMessage {
                Text("오류: \(errorMessage)")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("저장한 분석")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("AppBackgroundColor"))
        .sheet(isPresented: $store.showingDetail) {
            if let selectedItem = store.selectedItem {
                AIHistoryDetailView(
                    item: selectedItem,
                    onDismiss: { store.send(.dismissDetail) }
                )
            }
        }
    }
}

struct HistoryItemRow: View {
    let item: AnalyzeHistoryData
    let onTap: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH:mm"
        return formatter.string(from: item.timestamp)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(formattedDate)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        AIHistoryView(store: Store(initialState: AIHistoryFeature.State()) {
            AIHistoryFeature()
        })
    }
}
