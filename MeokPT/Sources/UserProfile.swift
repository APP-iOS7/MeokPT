//
//  UserProfile.swift
//  MeokPT
//
//  Created by 김동영 on 5/13/25.
//

struct UserProfile: Equatable, Codable {
    let nickname: String?
    let profileImageUrl: String?
    let postItems: [String]?

    // Firestore에서 NSNull을 nil로, 빈 문자열도 nil처럼 취급하여 닉네임 설정 여부 판단
    var isNicknameActuallySet: Bool {
        guard let nn = nickname, !nn.isEmpty else { return false }
        return true
    }
}
