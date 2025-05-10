//
//  DetailView.swift
//  MeokPT
//
//  Created by 김동영 on 5/10/25.
//

// DietDetailView.swift 파일 생성
import SwiftUI
import ComposableArchitecture

struct DietDetailView: View {
    let store: StoreOf<DietFeature>
    
    var body: some View {
        VStack {
            Text("식단 상세 페이지")
                .font(.title)
                .padding()
            
        }
        .navigationTitle("상세 정보")
        .background(Color("AppBackgroundColor"))
    }
}
