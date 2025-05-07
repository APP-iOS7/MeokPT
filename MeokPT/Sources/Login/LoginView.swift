//
//  LoginView.swift
//  MeokPT
//
//  Created by 김동영 on 5/7/25.
//

import SwiftUI

struct LoginView: View {
    
    @State private var emailText: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack{
            VStack {
                VStack(alignment: .leading) {
                    Text("이메일")
                        .font(.body)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    Spacer().frame(height: 16)
                    VStack {
                        TextField(
                            "",
                            text: $emailText,
                            prompt: Text(verbatim: "example@example.com")
                        )
                        Rectangle()
                            .frame(height: 1) // 밑줄 두께
                            .foregroundColor(Color(.placeholderText)) // 밑줄 색상
                    }
                    Spacer().frame(height: 36)
                    HStack {
                        Text("비밀번호")
                            .font(.body)
                            .foregroundStyle(Color("AppSecondaryColor"))
                        Spacer()
                        Text("6자 이상, 영문, 숫자")
                            .font(.caption2)
                            .foregroundStyle(Color(.placeholderText))
                    }
                    Spacer().frame(height: 16)
                    VStack {
                        TextField(
                            "",
                            text: $password,
                            prompt: Text(verbatim: "******")
                        )
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.placeholderText))
                    }
                }
                
                Spacer().frame(height: 70)
                
                Button(action: {}) {
                    ZStack {
                        HStack {
                            Spacer().frame(width: 36)
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                            Spacer()
                            
                        }
                        HStack {
                            Spacer().frame(width: 36)
                            Text("이메일/비밀번호로 로그인")
                                .font(.body)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .frame(width: 320, height: 60)
                .background(Color("AppTintColor"))
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 16)
                
                Button(action: {}) {
                    ZStack {
                        HStack {
                            Spacer().frame(width: 36)
                            Image(systemName: "apple.logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                                .foregroundStyle(.background)
                            Spacer()
                        }
                        HStack {
                            Spacer().frame(width: 36)
                            Text("Apple로 로그인")
                                .font(.body)
                                .foregroundStyle(.background)
                        }
                    }
                }
                .frame(width: 320, height: 60)
                .background(.primary)
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 16)
                
                Button(action: {}) {
                    ZStack {
                        HStack {
                            Spacer().frame(width: 36)
                            Image("kakaoLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                            Spacer()
                        }
                        HStack {
                            Spacer().frame(width: 36)
                            Text("카카오톡으로 로그인")
                                .font(.body)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .frame(width: 320, height: 60)
                .background(.yellow)
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 40)
                Divider().frame(width: 160).padding()
                Button(action: {}) {
                    Text("회원가입")
                        .font(.headline)
                        .foregroundStyle(Color("AppTintColor"))
                }
                
            }
            .padding(.horizontal, 24)
            .navigationTitle("회원가입 / 로그인")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color("AppBackgroundColor"))
        }
    }
}

#Preview {
    LoginView()
}
