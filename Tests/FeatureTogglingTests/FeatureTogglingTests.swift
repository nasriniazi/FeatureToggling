import XCTest
@testable import FeatureToggling

final class FeatureTogglingTests: XCTestCase {
    var manager :FeatureToggleService!
let featuresFileName = "FeatureToggles"
    override func setUpWithError() throws {
        guard let  provider = LocalProviderTests().providerWithFileNamed(featuresFileName) else {return}
        
        self.manager = FeatureToggleService(provider: provider)
    }
    func testNotThrowError_WhenLoadToggles(){
        XCTAssertNoThrow( try? manager.loadToggles {_ in })
       
    }
    func testNotThrowError_WhenUpdateFeaturesList(){
        XCTAssertNoThrow( try? manager.updateFeaturesList(features: []) )
       
    }
    func testInitializationOfFeatureToggleService(){
        let provider = LocalProviderTests().providerWithFileNamed(featuresFileName)
    
        XCTAssertEqual(provider, self.manager.provider as? LocalProvider)
    }
    func testLoadToggles(){
        let result =  [FeaturesWithState(feature:"+",enabled:true),FeaturesWithState(feature:"-",enabled:true),FeaturesWithState(feature:"*",enabled:true),FeaturesWithState(feature:"/",enabled:true)]
        try! setUpWithError()
        try! manager.loadToggles { features in
            XCTAssertEqual(features, result)
        }
    }
    func testUpdateFeaturesList(){
        let editedFeatures = [FeaturesWithState(feature:"+",enabled:false),FeaturesWithState(feature:"-",enabled:true),FeaturesWithState(feature:"*",enabled:true),FeaturesWithState(feature:"/",enabled:false)]
        try! manager.updateFeaturesList(features: editedFeatures)
        try! manager.loadToggles{ featuresAfterUpdate in
            XCTAssertEqual(editedFeatures, featuresAfterUpdate)
        }
    }
    func testIsEnabled(){
        let editedFeatures = [FeaturesWithState(feature:"+",enabled:false),FeaturesWithState(feature:"-",enabled:true),FeaturesWithState(feature:"*",enabled:true),FeaturesWithState(feature:"/",enabled:false)]
        try! manager.updateFeaturesList(features: editedFeatures)
        let featureState = manager.isEnabled("+")
        let expedtedState = false
        XCTAssertEqual(featureState, expedtedState)
    }

}
