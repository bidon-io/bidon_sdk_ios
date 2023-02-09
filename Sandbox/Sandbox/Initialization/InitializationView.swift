//
//  InitializationVIew.swift
//  Sandbox
//
//  Created by Stas Kochkin on 05.09.2022.
//

import Foundation
import SwiftUI
import BidOn


struct InitializationView: View {
    @EnvironmentObject var vm: InitializationViewModel
    
    private var appVersion: String {
        let appVersion = Bundle.main.versionString("CFBundleShortVersionString")
        let buildVersion = Bundle.main.versionString("CFBundleVersion")
        
        return "\(appVersion)(\(buildVersion))"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    if vm.isInitializing {
                        AppProgressView()
                    }
                    
                    List {
                        Section(header: Text("Base URL")) {
                            ForEach(vm.hosts) { host in
                                HostView(host: host, selected: $vm.host)
                            }
                        }
                        
                        Section(header: Text("Permissions")) {
                            ForEach(vm.permissions) {
                                PermissionView($0)
                            }
                        }
                    }
                    .disabled(vm.isInitializing)
                    .listStyle(.automatic)
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Button(action: vm.initialize) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(vm.isInitializing ? Color.secondary : Color.blue)
                                Text(vm.isInitializing ? "Initializing..." : "Initialize")
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .frame(height: 44)
                        }
                        .padding(.horizontal)
                        .disabled(vm.isInitializing)
                        
                        VStack(alignment: .leading) {
                            Text("BidOn SDK: ") + Text("v\(BidOnSdk.sdkVersion)").bold()
                            Text("Bundle ID: ") + Text(Bundle.main.bundleIdentifier ?? "").bold()
                            Text("App Key: ") + Text(Constants.BidOn.appKey).bold()
                            Text("App Version: ") + Text(appVersion).bold()
                        }
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationViewStyle(.stack)
    }
}


private extension Bundle {
    func versionString(_ key: String) -> String {
        return (object(forInfoDictionaryKey: key) as? String) ?? ""
    }
}
