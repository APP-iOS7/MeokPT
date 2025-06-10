import SwiftUI
import ComposableArchitecture
import _PhotosUI_SwiftUI
import Kingfisher

struct CommunityEditView: View {
    enum Field: Hashable {
        case title, content
    }
    @FocusState private var focusedField: Field?
    @Bindable var store: StoreOf<CommunityEditFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 제목 입력
                VStack {
                    TextField("제목", text: $store.title)
                        .focused($focusedField, equals: .title)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color(.placeholderText))
                }
                .padding(.horizontal, 16)
                
                // 내용 입력
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .frame(height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                        )
                    TextEditor(text: $store.content)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .cornerRadius(20)
                        .frame(height:160)
                        .focused($focusedField, equals: .content)
                    if store.content.isEmpty {
                            Text("내용")
                        .padding(16)
                        .foregroundStyle(Color(.placeholderText))
                    }
                }
                
                Button(action: {
                    focusedField = nil
                    store.send(.presentMealSelectionSheet)
                }) {
                    if let diet = store.selectedDiet {
                        CommunityDietSelectView(diet: diet)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .frame(height: 160)
                            .overlay(
                                HStack {
                                    Image(systemName: "plus")
                                    Text("식단 선택")
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("사진 (선택)")
                        .font(.body)
                        .foregroundStyle(Color("AppSecondaryColor"))
                        .padding(.leading, 8)

                    PhotosPicker(
                        selection: $store.selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        imageDisplayView
                            .frame(height: 210)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }

                Button(action: {
                    focusedField = nil
                    store.showAlert = true
                }) {
                    HStack {
                        Text(store.isUploading ? "사진 업로드 중" : "글 수정")
                        if store.isUploading {
                            ProgressView()
                                .tint(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("AppTintColor"))
                    .cornerRadius(30)
                }
                .font(.headline.bold())
                .foregroundStyle(.black)
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                .disabled(store.postInvalid || store.isUploading)
                .alert("글을 수정합니다.", isPresented: $store.showAlert) {
                    Button("취소", role: .cancel) {}
                    Button("수정") {
                        store.send(.submitButtonTapped)
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("글 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color("AppBackgroundColor"))
        .sheet(item: $store.scope(state: \.mealSelectionSheet, action: \.mealSelectionAction)) { store in
            NavigationStack {
                MealSelectionView(store: store)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
    }
    
    private var imageDisplayView: some View {
        Group {
            if let selectedImage = store.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageUrl = store.uploadedImageUrl {
                KFImage(imageUrl)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .onFailure { error in
                        print("KFImage load failed: \(error.localizedDescription)")
                    }
                    .scaledToFill()
            } else {
                Image(systemName: "photo.badge.plus")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Color.primary.opacity(0.7))
                    .frame(width: 100, height: 90)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        CommunityEditView(
            store: Store(initialState: CommunityEditFeature.State(communityPost: dummyCommunityPost)) {
                CommunityEditFeature()
            }
        )
    }
}
