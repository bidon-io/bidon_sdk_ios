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
                        
                        Section(header: Text("Settings")) {
                            LogLevelView(logLevel: $vm.logLevel)
                        }
                        
                        Section(
                            header: HStack {
                                Text("Demand Source Adapters")
                                Spacer()
                                Button(action: vm.registerDefaultAdapters) {
                                    Text("Register all")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10, weight: .light))
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.accentColor)
                                        )
                                }
                            }
                        ) {
                            AdaptersView(adapters: $vm.adapters)
                        }
                    }
                    .disabled(!vm.initializationState.isIdle)
                    .listStyle(.automatic)
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Button(action: initialize) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(vm.initializationState.accentColor)
                                Text(vm.initializationState.text)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .frame(height: 44)
                        }
                        .padding(.horizontal)
                        .disabled(!vm.initializationState.isIdle)
                        
                        VStack(alignment: .leading) {
                            Text("Mediation: ") + Text(AdverstisingServiceProvider.shared.service.mediation.rawValue.capitalized + " v" + AdverstisingServiceProvider.shared.service.verstion).bold()
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
                
                if vm.initializationState.isAnimating {
                    Color(UIColor.systemGroupedBackground)
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.25)
                        .transition(.scale.combined(with: .opacity))
                    
                    AppProgressView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationViewStyle(.stack)
    }
    
    private func initialize() {
        Task {
            await vm.initialize()
        }
    }
}


private extension Bundle {
    func versionString(_ key: String) -> String {
        return (object(forInfoDictionaryKey: key) as? String) ?? ""
    }
}


private extension InitializationViewModel.InitializationState {
    var isAnimating: Bool {
        return self == .initilizing
    }
    
    var isIdle: Bool {
        return self == .idle
    }
    
    var text: String {
        switch self {
        case .idle: return "Initilize"
        case .initilizing: return "Initilizing..."
        case .initialized: return "Initialized"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .idle: return Color.accentColor
        case .initilizing: return Color.gray
        case .initialized: return Color.green
        }
    }
}
