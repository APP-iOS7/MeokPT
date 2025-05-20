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
    
    var foodName: String { FOOD_NM_KR?.replacingOccurrences(of: "_", with: ", ") ?? "" }
    var calorie: Double { Double(AMT_NUM1?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var protein: Double { Double(AMT_NUM3?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var fat: Double { Double(AMT_NUM4?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var carbohydrate: Double { Double(AMT_NUM6?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var dietaryFiber: Double { Double(AMT_NUM8?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var sodium: Double { Double(AMT_NUM13?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
    var servingSize: Double { Double(Z10500?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0 }
}
