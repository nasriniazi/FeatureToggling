//
//  File.swift
//  
//
//  Created by nasrin niazi on 2023-02-13.
//

import Foundation
import Coordinator
import UIKit

protocol FeaturesCoordinatorProtocol: CoordinatorProtocol {
    func showFeaturesViewController(manager:FeatureToggleService)
}
public class FeaturesCoordinator: FeaturesCoordinatorProtocol {
    
   public var DI: [String : Any]?
   
   weak public var finishDelegate: CoordinatorFinishDelegate?

   public var navigationController: UINavigationController

   public var childCoordinators: [CoordinatorProtocol] = []
   
    public var type: CoordinatorType { .features }

   required public init(_ navigationController: UINavigationController) {
       self.navigationController = navigationController
   }
   public func start(){
       if let manager = DI?["manager"] as? FeatureToggleService{
        showFeaturesViewController(manager: manager)
       }
       else{
           self.finish()
       }
   }
   
    func showFeaturesViewController(manager:FeatureToggleService){
       let featuresVC: FeatureListViewController = FeatureListViewController.getInstance(featureManager: manager)
        
       navigationController.pushViewController(featuresVC, animated: true)
   }
}
