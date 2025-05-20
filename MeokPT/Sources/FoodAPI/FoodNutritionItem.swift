//
//  FoodNutritionItem.swift
//  MeokPT
//
//  Created by 김동영 on 5/20/25.
//

import Foundation

struct FoodNutritionItem: Decodable, Equatable, Identifiable {
    let ITEM_REPORT_NO: String?
    let FOOD_NM_KR: String?
    let DB_CLASS_NM: String?
    let AMT_NUM1: String?
    let AMT_NUM3: String?
    let AMT_NUM4: String?
    let AMT_NUM6: String?
    let AMT_NUM8: String?
    let AMT_NUM13: String?
    let Z10500: String?
    
    var id: String { ITEM_REPORT_NO ?? UUID().uuidString }
    
    var foodName: String {
        if let correctedName = foodNameCorrections[FOOD_NM_KR ?? ""] {
            return correctedName
        } else {
            return FOOD_NM_KR?.replacingOccurrences(of: "_", with: ", ") ?? ""
        }
    }
    var calorie: Double { Double(AMT_NUM1?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var protein: Double { Double(AMT_NUM3?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var fat: Double { Double(AMT_NUM4?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var carbohydrate: Double { Double(AMT_NUM6?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var dietaryFiber: Double { Double(AMT_NUM8?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var sodium: Double { Double(AMT_NUM13?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var servingSize: Double { Double(Z10500?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
}

private let foodNameCorrections: [String: String] = [
    "머핀케��": "머핀케잌",
    "까폼 랭��": "까폼 랭쎕",
    "식당용케�": "식당용케챂",
    "토마토케�": "토마토케챂",
    "C콘�� 골드": "C콘칲 골드",
    "켄터키 직화 �-빠": "켄터키 직화 핟-빠",
    "프��츠 콜드브루": "프릳츠 콜드브루",
    "�┚苛玲좁梔� 알곡": "뀰초당옥수수 알곡",
    "프��츠 콜드브루 1000": "프릳츠 콜드브루 1000",
    "롯데 켄터키 직화 �-빠": "롯데 켄터키 직화 핟-빠",
    "으�X으�X 홍삼배도라지": "으쌰으쌰 홍삼배도라지",
    "플레이플푸디 그린�y�": "플레이플푸디 그린챱챱",
    "돈카츠마�R 용암블럭치즈": "돈카츠마켙 용암블럭치즈",
    "프��츠 콜드브루 딥슬립": "프릳츠 콜드브루 딥슬립",
    "프��츠 콜드브루 올드독": "프릳츠 콜드브루 올드독",
    "켄터키 직화 �-빠 매콤화끈": "켄터키 직화 핟-빠 매콤화끈",
    "신이어마�R 할매마늘순대국밥": "신이어마켙 할매마늘순대국밥"
]

// 검색어 -> 품목제조보고번호 매핑 (예시: "콘칲" or "콘칩" -> "C콘칲 골드"의 보고번호)
let foodNameToReportIdMap: [String: String] = [
    "콘칩": "19870461068157",
    "C콘칲 골드": "19870461068157",
    "머핀케잌": "2001036244422",
    "까폼 랭쎕": "202403711232",
    "식당용케챂": "19730619001393",
    "토마토케챂": "19730619001392",
    "켄터키 직화 핟-빠": "19980448009329",
    "프릳츠 콜드브루": "2014036252420",
    "뀰초당옥수수 알곡": "2000063100137",
    "프릳츠 콜드브루 1000": "2014036252419",
    "롯데 켄터키 직화 핟-빠": "19980448009344",
    "으쌰으쌰 홍삼배도라지": "20090368428585",
    "플레이플푸디 그린챱챱": "20090517030139",
    "돈카츠마켙 용암블럭치즈": "20030262055278",
    "프릳츠 콜드브루 딥슬립": "2014036252494",
    "프릳츠 콜드브루 올드독": "2014036252459",
    "켄터키 직화 핟-빠 매콤화끈": "19980448009338",
    "신이어마켙 할매마늘순대국밥": "20210202173302",
]
