//
//  EmptyNutrientView.swift
//  MeokPT
//
//  Created by 김동영 on 5/30/25.
//

import SwiftUI

struct EmptyNutrientView: View {
    
    var body: some View {
        HStack {
            EachNutrientView(name: "탄수화물")
            Spacer()
            Divider()
            Spacer()
            EachNutrientView(name: "단백질")
            Spacer()
            Divider()
            Spacer()
            EachNutrientView(name: "지방")
        }
    }
}

private struct EachNutrientView: View {
    let name: String
    
    var body: some View {
        VStack(alignment: .center) {
            Text(name)
                .font(.caption)
                .foregroundColor(Color("AppSecondaryColor"))
            Spacer().frame(height:4)
            Text("--.-g")
                .font(.body)
        }
    }
}

#Preview {
    EmptyNutrientView()
}
