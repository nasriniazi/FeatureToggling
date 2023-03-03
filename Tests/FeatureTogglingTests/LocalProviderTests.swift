//
//  LocalProviderTests.swift
//  
//
//  Created by nasrin niazi on 2023-02-03.
//

import XCTest
import Foundation
@testable import FeatureToggling

class LocalProviderTests: XCTestCase {
 
    var provider:LocalProvider!
    override func setUpWithError() throws {
    provider = providerWithFileNamed("FeatureToggles")

    }
    func providerWithFileNamed(_ fileName: String) -> LocalProvider? {
        let bundle = Bundle.currentModule(name: "FeatureToggling")
        if let url = bundle.url(forResource: fileName, withExtension: "json", subdirectory: "JSON") {
            let provider = LocalProvider(jsonURL: url)
            return provider
        } else {
            debugPrint("Could not find the json file: \(fileName) in bundle: \(bundle)")
            return nil
        }
    }

    func testCreateProvider_Throws_WhenWrongUrl(){
        let provider = providerWithFileNamed("FeatureToggle")
        XCTAssertNil(provider)
    }

    func testFetchFeatureToggles_WhenLoadDefaultConfig() {
        self.provider.clearData()
        try! setUpWithError()
        let result =  [FeaturesWithState(feature:"+",enabled:true),FeaturesWithState(feature:"-",enabled:true),FeaturesWithState(feature:"*",enabled:true),FeaturesWithState(feature:"/",enabled:true)]
        try! provider!.fetchFeatureToggles()
        let features:[FeaturesWithState] = provider.features()
             XCTAssertEqual(features , result)
        
    }
    func testThrowLoadError_WhenfetchFeature_WrongDataFormat(){
        self.provider.clearData()
        provider = providerWithFileNamed("LocalFeatures_test")
        XCTAssertThrowsError(try provider.fetchFeatureToggles()) { error in
        XCTAssertEqual(error as! FeatureTogglingErrors, .loadError)
        }
    }

    func testUpdateFeatureToggleSource(){
        let editedFeatures = [FeaturesWithState(feature:"+",enabled:false),FeaturesWithState(feature:"-",enabled:true),FeaturesWithState(feature:"*",enabled:true),FeaturesWithState(feature:"/",enabled:false)]
        try! provider.updateFeatureToggleSource(editedFeatures: editedFeatures)
        try! provider.fetchFeatureToggles()
        let featuresAfterUpdate = provider.features()
        XCTAssertEqual(editedFeatures, featuresAfterUpdate)
        
    }
    override func tearDownWithError() throws {
        provider = nil
    }


}
