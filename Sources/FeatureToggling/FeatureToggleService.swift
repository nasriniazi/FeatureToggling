//
//  File.swift
//  
//
//  Created by nasrin niazi on 2023-01-31.
//

import Foundation
import LogManager

public final class FeatureToggleService {
    
    var provider: FeatureToggleProvider!
    public enum FeatureFilter {
        case enabled
        case disabled
        case all
    }
    public init(provider:FeatureToggleProvider) {
        Log.featureTogglingLog.log("FeatureToggleService -Init")
        self.provider = provider
    }
    public func loadToggles(_ completion: @escaping ([FeaturesWithState]) -> Void)throws{
        
        Log.featureTogglingLog.info("FeatureToggleService -start of loadToggles method ")
        try provider.fetchFeatureToggles()
        let features = provider.features()
        completion(features)
        Log.featureTogglingLog.log("FeatureToggleService -end of loadToggles method-features=\(features) ")
        
        
        //        try provider.fetchFeatureToggles { features in
        //            if  features.count>0 {
        //                completion(features)
        //                Log.featureTogglingLog.log("FeatureToggleService -end of loadToggles method-features=\(features) ")
        //            }
        //        }
    }
    public func getFeatureNames(_ filter:FeatureFilter,_ completion: @escaping ([String]) -> Void)throws{
        let featuresWithStates = provider.features()
        switch filter {
        case .enabled:
            let enabledFeatures = featuresWithStates.filter { $0.enabled == true }
            completion(enabledFeatures.map{$0.feature})
            
        case .disabled:
            let disabledFeatures = featuresWithStates.filter { $0.enabled == false }
            completion(disabledFeatures.map{$0.feature})
            
        case .all:
            completion(featuresWithStates.map{$0.feature})
        }
    }
    public func updateFeature(featureName:String,state:Bool)throws{
        Log.featureTogglingLog.info("FeatureToggleService -start of updateFeature for \(featureName) with state=\(state) ")
        var featuresWithStates = provider.features()
        if let firstSuchElement = featuresWithStates.firstIndex(where: { $0.feature == featureName })
            .map({featuresWithStates[$0].enabled = state}){
            try provider.updateFeatureToggleSource(editedFeatures: featuresWithStates)
            Log.featureTogglingLog.info("FeatureToggleService-end of updateFeature method- updatedFeatures=\(featuresWithStates)")
        }
    }
    public func updateFeaturesList(features:[FeaturesWithState])throws{
        Log.featureTogglingLog.info("FeatureToggleService -start of updateFeaturesList method with featues=\(features) ")
        guard let provider = self.provider else {return}
        try provider.updateFeatureToggleSource(editedFeatures: features)
        Log.featureTogglingLog.info("FeatureToggleService-end updateFeaturesList method- updatedFeatures=\(provider.features())")
    }
    public func isEnabled(_ featureName: String) -> Bool {
        Log.featureTogglingLog.info("FeatureToggleService -start of isEnabled method for feature \(featureName)")
        let featuresWithStates = provider.features()
        let feature = featuresWithStates.first(where: { $0.feature == featureName })
        Log.featureTogglingLog.info("FeatureToggleService -end of isEnabled method - returned state is=\(feature?.enabled ?? false)")
        return feature?.enabled ?? false
    }
}
