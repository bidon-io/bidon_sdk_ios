//
//  ConfigurationRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 11.08.2022.
//

import Foundation


final class ConfigurationRequestBuilder: BaseRequestBuilder {
    var adapters: AdaptersInfo {
        let adapters: [Adapter] = adaptersRepository.all()
        
        return AdaptersInfo(adapters: adapters)
    }
}
