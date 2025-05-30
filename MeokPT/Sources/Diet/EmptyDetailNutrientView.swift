//
//  EmptyDetailNutrientView.swift
//  MeokPT
//
//  Created by 김동영 on 5/30/25.
//

import SwiftUI

struct EmptyDetailNutrientView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                EachNutrientView(name: "탄수화물")
                    .frame(maxWidth: .infinity)
                Divider()
                EachNutrientView(name: "단백질")
                    .frame(maxWidth: .infinity)
                Divider()
                EachNutrientView(name: "지방")
                    .frame(maxWidth: .infinity)

            }
            HStack {
                EachNutrientView(name: "식이섬유")
                    .frame(maxWidth: .infinity)
                Divider()
                EachNutrientView(name: "당류")
                    .frame(maxWidth: .infinity)
                Divider()
                EachNutrientView(name: "나트륨")
                    .frame(maxWidth: .infinity)

            }
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
            name == "나트륨" ? Text("--.- mg") : Text("--.- g")
                .font(.body)
        }
    }
}

#Preview {
    EmptyDetailNutrientView()
}
