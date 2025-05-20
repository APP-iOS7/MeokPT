//
//  FoodNutritionAPIResponse.swift
//  MeokPT
//
//  Created by 김동영 on 5/20/25.
//

import Foundation

struct FoodNutritionAPIResponse: Decodable, Equatable {
    let header: Header
    let body: Body?
    
    struct Header: Decodable, Equatable {
        let resultCode: String
        let resultMsg: String
    }
    
    struct Body: Decodable, Equatable {
        let pageNo: Int?
        let totalCount: Int?
        let numOfRows: Int?
        let items: [FoodNutritionItem]?
    }
}

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
    
    var displayCalorie: String { (AMT_NUM1 ?? "N/A") + " kcal" }
    var displayProtein: String { (AMT_NUM3 ?? "N/A") + " g" }
    var displayFat: String { (AMT_NUM4 ?? "N/A") + " g" }
    var displayCarbohydrate: String { (AMT_NUM6 ?? "N/A") + " g" }
    var dietaryFiber: String { (AMT_NUM8 ?? "N/A") + " g" }
    var sodium: String { (AMT_NUM13 ?? "N/A") + " mg" }
    var servingSize: String { Z10500 ?? "N/A" }
}