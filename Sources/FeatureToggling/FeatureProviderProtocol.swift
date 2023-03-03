//
//  File.swift
//  
//
//  Created by nasrin niazi on 2023-02-01.
//

import Foundation
public typealias FeatureToggleCallback = ([FeaturesWithState]) -> Void

public protocol FeatureToggleProvider {
//    func fetchFeatureToggles(_ completion: @escaping FeatureToggleCallback)throws
    func fetchFeatureToggles()throws

    func updateFeatureToggleSource( editedFeatures:[FeaturesWithState])throws
    func features() -> [FeaturesWithState] 

}
