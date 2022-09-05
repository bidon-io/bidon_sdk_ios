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
                Color(UIColor.secondarySystemBackground)
                    .edgesIgnoringSafeArea(.all)
                
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
                .listStyle(.automatic)
                
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    Button(action: vm.initialize) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                            Text("Initialize")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(height: 44)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("BidOn SDK: ") + Text("v\(BidOnSdk.sdkVersion)").bold()
                        Text("Bundle ID: ") + Text(Bundle.main.bundleIdentifier ?? "").bold()
                        Text("App Key: ") + Text(Constants.appKey).bold()
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationViewStyle(.stack)
        .progressOverlay(vm.isInitializing)
    }
}


private extension Bundle {
    func versionString(_ key: String) -> String {
        return (object(forInfoDictionaryKey: key) as? String) ?? ""
    }
}
