import SwiftUI
import ComposableArchitecture
import _PhotosUI_SwiftUI
import Kingfisher

struct ProfileSettingView: View {
    @Bindable var store: StoreOf<ProfileSettingFeature>
    @FocusState private var nickNameFocused: Bool

    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 70)
                Group {
                    if let selectedImage = store.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let imageUrl = store.uploadedImageUrl {
                        KFImage(imageUrl)
                            .resizable()
                            .placeholder {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(Color("AppSecondaryColor").opacity(0.5))
                            }
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundStyle(Color("App ProfileColor").opacity(0.5))
                    }
                }
                .frame(width: 104, height: 104)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(UIColor.separator), lineWidth: 1))
                
                Spacer().frame(height: 20)

                PhotosPicker(
                    selection: $store.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("프로필 사진 변경")
                        .font(.subheadline.bold())
                        .foregroundColor(.black)
                        .frame(width: 176, height: 50)
                        .background(Color("AppTintColor"))
                        .clipShape(.rect(cornerRadius: 25))
                }
                
                if store.isUploading {
                    ProgressView("업로드 중...", value: store.uploadProgress, total: 1.0)
                        .padding(.top, 10)
                        .frame(width: 176, height:80)
                } else {
                    Spacer().frame(width: 176, height:80)
                }
                
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("닉네임")
                        .font(.callout)
                        .foregroundColor(Color.gray)
                    TextField(
                        "",
                        text: $store.nickName,
                        prompt: Text(verbatim: "2자 이상 입력해주세요")
                    )
                    .autocapitalization(.none)
                    .focused($nickNameFocused)
                    .padding(.vertical, 10)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(nickNameFocused ? Color("AppTintColor") : Color(.placeholderText))
                }
                if let saveError = store.saveProfileError {
                    Text(saveError)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                Spacer()
                Button(action: {
                    store.send(.saveProfile)
                }) {
                    HStack {
                        Spacer()
                        if store.isSavingProfile {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("프로필 저장")
                        }
                        Spacer()
                    }
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .frame(height: 60)
                .background(Color("AppTintColor"))
                .clipShape(.rect(cornerRadius: 30))
                .buttonStyle(PlainButtonStyle())
                .disabled(store.isUploading || store.isSavingProfile)
                .opacity((store.isUploading || store.isSavingProfile) ? 0.7 : 1.0)

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 30)
            .navigationTitle("프로필 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        store.send(.cancelButtonTapped)
                    }
                }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .contentShape(Rectangle())
            .onTapGesture {
                nickNameFocused = false
            }
        }
        .background(Color("AppBackgroundColor"))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSettingView(
            store: Store(
                initialState: ProfileSettingFeature.State()) {
                ProfileSettingFeature()
            }
        )
    }
}
