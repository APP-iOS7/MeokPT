//
//  ProfileSettingView.swift
//  MeokPT
//
//  Created by 김동영 on 5/12/25.
//

import SwiftUI
import ComposableArchitecture
import _PhotosUI_SwiftUI

struct ProfileSettingView: View {
    @Bindable var store: StoreOf<ProfileSettingFeature>
    
    @FocusState private var nickNameFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 100)
                if let selectedImage = store.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 104, height: 104)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 104, height: 104)
                        .foregroundStyle(Color("AppSecondaryColor"))
                }
                Spacer().frame(height: 26)
                PhotosPicker(
                    selection: $store.selectedItem, matching: .images, photoLibrary: .shared()) {
                        Text("프로필 사진 변경")
                            .font(.subheadline.bold())
                            .foregroundStyle(.black)
                            .frame(width: 176,height: 60)
                            .background(Color("AppTintColor"))
                            .clipShape(.rect(cornerRadius: 40))
                    }
                Spacer().frame(height: 77)
                TextField(
                    "",
                    text: $store.nickName,
                    prompt: Text(verbatim: "닉네임")
                )
                .autocapitalization(.none)
                .focused($nickNameFocused)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.placeholderText))
                Spacer()
                Button(action: {}) {
                    Text("프로필 저장")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .frame(height: 60)
                .background(Color("AppTintColor"))
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .navigationTitle("프로필 사진, 닉네임 설정")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .contentShape(Rectangle())
            .onTapGesture {
                nickNameFocused = false
            }
        }
        .scrollDisabled(true)
        .background(Color("AppBackgroundColor"))
    }
}

#Preview {
    ProfileSettingView(
        store: Store(initialState: ProfileSettingFeature.State()) {
            ProfileSettingFeature()
        }
    )
}
