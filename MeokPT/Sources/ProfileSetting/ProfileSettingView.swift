import SwiftUI
import ComposableArchitecture
import _PhotosUI_SwiftUI
import Kingfisher

struct ProfileSettingView: View {
    @Bindable var store: StoreOf<ProfileSettingFeature>
    @FocusState private var nickNameFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)

                // MARK: - 프로필 이미지
                VStack(spacing: 12) {
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
                                        .foregroundStyle(.gray.opacity(0.5))
                                }
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                    .frame(width: 104, height: 104)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

                    PhotosPicker(
                        selection: $store.selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("프로필 사진 변경", systemImage: "photo.on.rectangle")
                            .font(.subheadline.bold())
                            .frame(width: 180, height: 44)
                            .background(Color("AppTintColor"))
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                    }

                    if store.isUploading {
                        ProgressView("업로드 중...", value: store.uploadProgress, total: 1.0)
                            .font(.caption)
                            .frame(width: 180)
                    }

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - 닉네임 입력
                VStack(alignment: .leading, spacing: 6) {
                    Text("닉네임")
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    TextField("", text: $store.nickName, prompt: Text("2자 이상 입력해주세요"))
                        .autocapitalization(.none)
                        .focused($nickNameFocused)
                        .padding(.vertical, 10)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(nickNameFocused ? Color("AppTintColor") : Color(.placeholderText))

                    if let saveError = store.saveProfileError {
                        Text(saveError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - 저장 버튼
                Button {
                    store.send(.saveProfile)
                } label: {
                    HStack {
                        Spacer()
                        if store.isSavingProfile {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Label("프로필 저장", systemImage: "checkmark.circle.fill")
                        }
                        Spacer()
                    }
                    .font(.headline.bold())
                    .frame(height: 56)
                    .background(Color("AppTintColor"))
                    .foregroundColor(.black)
                    .clipShape(Capsule())
                }
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
                    .foregroundStyle(Color("AppTintColor"))
                }
            }
            .onTapGesture {
                nickNameFocused = false
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
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
